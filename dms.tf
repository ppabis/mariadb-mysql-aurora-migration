resource "aws_dms_endpoint" "source" {
  secrets_manager_access_role_arn = aws_iam_role.DmsRole.arn
  secrets_manager_arn             = aws_secretsmanager_secret.creds["MariaDB"].arn
  endpoint_type                   = "source"
  engine_name                     = "mariadb"
  endpoint_id                     = "mariadb-source"
}

resource "aws_dms_endpoint" "target" {
  secrets_manager_access_role_arn = aws_iam_role.DmsRole.arn
  secrets_manager_arn             = aws_secretsmanager_secret.creds["MySQL57"].arn
  endpoint_type                   = "target"
  engine_name                     = "mysql"
  endpoint_id                     = "mysql-target"
}

resource "aws_dms_replication_subnet_group" "subnets" {
  replication_subnet_group_id          = "dms-subnets"
  replication_subnet_group_description = "DMS Subnets in Production VPC"
  subnet_ids                           = aws_subnet.production[*].id
  depends_on                           = [aws_iam_role_policy_attachment.dms-vpc-policy]
}

resource "aws_security_group" "DMS-SG" {
  name   = "DMS-SG"
  vpc_id = aws_vpc.production.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_dms_replication_instance" "instance" {
  replication_subnet_group_id = aws_dms_replication_subnet_group.subnets.id
  replication_instance_class  = "dms.t2.micro"
  allocated_storage           = 20
  engine_version              = "3.5.1"
  vpc_security_group_ids      = [aws_security_group.DMS-SG.id]
  replication_instance_id     = "dms-instance"
}
