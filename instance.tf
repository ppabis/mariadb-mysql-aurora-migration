data "aws_ssm_parameter" "AL2023-ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-arm64"
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.production.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.6.50.0/24"
  availability_zone = "eu-west-1b"
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.production.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

resource "aws_route_table_association" "public-subnet" {
  route_table_id = aws_route_table.public-rtb.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_security_group" "manage-instance" {
  vpc_id = aws_vpc.production.id
  name   = "InstanceSG"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [null_resource.ec2-instance-connect-ip.triggers.ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "manage-instance" {
  instance_type               = "t4g.nano"
  ami                         = data.aws_ssm_parameter.AL2023-ami.value
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.manage-instance.id]
  tags = {
    Name = "manage-db"
  }
  depends_on = [aws_route_table_association.public-subnet]
  user_data  = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y mariadb105
  EOF
}

output "public_dns" {
  value = aws_instance.manage-instance.public_dns
}
