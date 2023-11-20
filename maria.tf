resource "aws_vpc" "production" {
  tags                 = { Name = "ProductionVPC" }
  cidr_block           = "10.6.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "production" {
  count             = 3
  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.6.${count.index}.0/24"
  availability_zone = join("", ["eu-west-1", ["a", "b", "c"][count.index]])
}

resource "aws_db_subnet_group" "MariaDB" {
  name       = "mariadb"
  subnet_ids = aws_subnet.production[*].id
}

resource "aws_security_group" "MariaDB" {
  vpc_id = aws_vpc.production.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.production.cidr_block]
  }
}

resource "aws_db_parameter_group" "MariaDB" {
  family = "mariadb10.6"
  name   = "mariadb-custom"
  parameter {
    name  = "binlog_format"
    value = "ROW"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "binlog_checksum"
    value        = "NONE"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "binlog_row_image"
    value        = "FULL"
  }
}

resource "aws_db_instance" "MariaDB" {
  engine                  = "mariadb"
  instance_class          = "db.t2.small"
  allocated_storage       = 20
  storage_type            = "gp3"
  engine_version          = "10.6"
  db_subnet_group_name    = aws_db_subnet_group.MariaDB.name
  publicly_accessible     = false
  backup_retention_period = 3
  password                = random_password.passwords["MariaDB"].result
  username                = "mariadb"
  vpc_security_group_ids  = [aws_security_group.MariaDB.id]
  skip_final_snapshot     = true
  parameter_group_name    = aws_db_parameter_group.MariaDB.name
}

output "mariadb-endpoint" {
  value = split(":", aws_db_instance.MariaDB.endpoint)[0]
}

output "mariadb-password" {
  value     = random_password.passwords["MariaDB"].result
  sensitive = true
}

resource "aws_secretsmanager_secret_version" "updated-mariadb" {
  secret_id = aws_secretsmanager_secret.creds["MariaDB"].id
  secret_string = jsonencode({
    engine   = "mariadb"
    username = "mariadb"
    password = random_password.passwords["MariaDB"].result
    host     = aws_db_instance.MariaDB.address
    port     = aws_db_instance.MariaDB.port
  })
}
