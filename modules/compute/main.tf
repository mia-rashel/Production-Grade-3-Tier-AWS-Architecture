
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

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

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y
yum install -y mysql

systemctl enable nginx
systemctl start nginx

# Wait for RDS to be ready
sleep 40

# Try connecting to database
mysql -h ${var.db_endpoint} -P 3306 -u ${var.db_username} -p${var.db_password} -e "CREATE DATABASE IF NOT EXISTS appdb;" 

if [ $? -eq 0 ]; then
  echo "DB CONNECTION SUCCESSFUL" > /usr/share/nginx/html/index.html
else
  echo "DB CONNECTION FAILED" > /usr/share/nginx/html/index.html
fi
EOF
)
}


resource "aws_autoscaling_group" "asg" {
  desired_capacity = 1
  max_size         = 2
  min_size         = 1

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
