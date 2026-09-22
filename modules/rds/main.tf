resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Project = var.project_name
  }
}

resource "aws_db_parameter_group" "postgres_params" {
  name        = "${var.project_name}-postgres-params"
  family      = "postgres15"

  parameter {
    name  = "max_connections"
    value = "500"
  }

  parameter {
    name  = "shared_buffers"
    value = "256MB"
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.project_name}-postgres"
  engine                  = "postgres"
  engine_version          = "15.3"
  instance_class          = var.instance_class
  allocated_storage       = var.storage_gb
  max_allocated_storage   = var.max_storage_gb
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.security_group_id]
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  multi_az                = true
  parameter_group_name    = aws_db_parameter_group.postgres_params.name

  tags = {
    Project = var.project_name
  }
}

output "postgres_endpoint" {
  value = aws_db_instance.postgres.address
}

output "postgres_port" {
  value = aws_db_instance.postgres.port
}
