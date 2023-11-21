resource "aws_db_instance" "MySQL" {
  engine                  = "mysql"
  instance_class          = "db.t2.small"
  allocated_storage       = 20
  storage_type            = "gp3"
  engine_version          = "5.7"
  db_subnet_group_name    = aws_db_subnet_group.MariaDB.name
  publicly_accessible     = false # Change this if you like
  backup_retention_period = 3
  password                = random_password.passwords["MySQL57"].result
  username                = "mysql57"
  vpc_security_group_ids  = [aws_security_group.MariaDB.id]
  skip_final_snapshot     = true
}

output "mysql-endpoint" {
  value = split(":", aws_db_instance.MySQL.endpoint)[0]
}

output "mysql-password" {
  value     = random_password.passwords["MySQL57"].result
  sensitive = true
}

resource "aws_secretsmanager_secret_version" "updated-mysql" {
  secret_id = aws_secretsmanager_secret.creds["MySQL57"].id
  secret_string = jsonencode({
    engine   = "mysql"
    username = "mysql57"
    password = random_password.passwords["MySQL57"].result
    host     = aws_db_instance.MySQL.address
    port     = aws_db_instance.MySQL.port
  })
}
