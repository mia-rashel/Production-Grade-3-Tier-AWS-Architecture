data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "app" {
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg]
  }

  user_data = base64encode(<<USERDATA
#!/bin/bash

yum update -y
amazon-linux-extras install nginx1 -y
yum install -y mysql php php-fpm

systemctl enable nginx
systemctl start nginx

systemctl enable php-fpm
systemctl start php-fpm

# Configure nginx to support PHP
cat <<NGINXCONF > /etc/nginx/conf.d/php.conf
server {
    listen 80 default_server;
    root /usr/share/nginx/html;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php\$ {
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
NGINXCONF

systemctl restart nginx

# Wait for database
sleep 40

# Test database connection
mysql -h ${var.db_endpoint} -P 3306 -u ${var.db_username} -p${var.db_password} -e "CREATE DATABASE IF NOT EXISTS appdb;"
DB_STATUS=$?

if [ $DB_STATUS -eq 0 ]; then
DB_MESSAGE="Connected Successfully"
DB_COLOR="green"
else
DB_MESSAGE="Connection Failed"
DB_COLOR="red"
fi

# Create request counter file
echo 0 > /usr/share/nginx/html/counter.txt

# Create dynamic dashboard
cat <<PHPFILE > /usr/share/nginx/html/index.php
<?php

\$counter_file = "counter.txt";

\$count = file_get_contents(\$counter_file);
\$count++;

file_put_contents(\$counter_file, \$count);

\$instance_id = file_get_contents("http://169.254.169.254/latest/meta-data/instance-id");
\$az = file_get_contents("http://169.254.169.254/latest/meta-data/placement/availability-zone");
\$ip = file_get_contents("http://169.254.169.254/latest/meta-data/local-ipv4");

?>

<!DOCTYPE html>
<html>
<head>
<title>AWS 3-Tier Architecture</title>

<style>

body {
font-family: Arial;
background:#f4f6f9;
text-align:center;
}

.container{
width:650px;
margin:auto;
margin-top:80px;
padding:30px;
background:white;
border-radius:10px;
box-shadow:0px 4px 20px rgba(0,0,0,0.1);
}

h1{
color:#232f3e;
}

.counter{
font-size:22px;
font-weight:bold;
color:#ff9900;
}

.status{
font-weight:bold;
color:$DB_COLOR;
}

</style>

</head>

<body>

<div class="container">

<h1>AWS 3-Tier Architecture Demo</h1>
<h3>Terraform Infrastructure</h3>

<p><b>Instance ID:</b> <?php echo \$instance_id; ?></p>
<p><b>Private IP:</b> <?php echo \$ip; ?></p>
<p><b>Availability Zone:</b> <?php echo \$az; ?></p>

<hr>

<p class="counter">
Requests served by this instance: <?php echo \$count; ?>
</p>

<hr>

<h3>Database Status</h3>
<p class="status">$DB_MESSAGE</p>

<p><b>DB Endpoint:</b> ${var.db_endpoint}</p>

<hr>

<p style="font-size:12px;color:gray">
ALB + Auto Scaling + RDS | Terraform Deployment
</p>

</div>

</body>
</html>

PHPFILE

USERDATA
  )
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  vpc_zone_identifier = var.private_subnets

  target_group_arns = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "cpu_policy" {
  name                   = "cpu-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_role.name
}