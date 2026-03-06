resource "aws_db_subnet_group" "db_subnets" {
  name       = "app-db-subnet-group"
  subnet_ids = var.private_subnets
}

resource "aws_db_instance" "db" {
  identifier              = "app-db"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"

  username                = var.db_username
  password                = var.db_password

  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [var.db_sg]

  publicly_accessible     = false
  storage_encrypted       = true
  skip_final_snapshot     = true

  backup_retention_period = 7
  multi_az = true
}
resource "aws_db_instance" "replica" {
  identifier              = "app-db-replica"

  replicate_source_db     = aws_db_instance.db.identifier

  instance_class          = "db.t3.micro"

  publicly_accessible     = false
  storage_encrypted       = true
    skip_final_snapshot     = true


  vpc_security_group_ids  = [var.db_sg]

  depends_on = [aws_db_instance.db]
}