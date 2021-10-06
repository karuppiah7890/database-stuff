terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.60.0"
    }
  }

  required_version = "1.0.7"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "redis_vpc" {
  cidr_block         = "10.0.0.0/16"
  instance_tenancy   = "default"
  enable_dns_support = true

  tags = {
    Name = "redis-vpc"
  }
}

resource "aws_subnet" "redis_subnet" {
  vpc_id     = aws_vpc.redis_vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "redis-subnet"
  }
}

resource "aws_key_pair" "redis_ssh_key" {
  key_name_prefix = "redis-ssh-key"
  public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFx7TEwvLYQEnPcH/eorh+4aAofEKR4bHisiy3Pia8FZ dummy@gmail.com"
}

resource "aws_security_group" "redis_security_group" {
  name        = "allow_redis_traffic"
  description = "Allow Redis traffic"
  vpc_id      = aws_vpc.redis_vpc.id
  tags = {
    Name = "allow-redis-traffic"
  }
}

resource "aws_security_group_rule" "redis_security_group_ingress" {
  type              = "ingress"
  description       = "Redis Traffic from the Internet"
  from_port         = 50379
  to_port           = 50379
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.redis_security_group.id
}

resource "aws_security_group_rule" "redis_security_group_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.redis_security_group.id
}

resource "aws_internet_gateway" "redis_internet_gateway" {
  vpc_id = aws_vpc.redis_vpc.id

  tags = {
    Name = "redis-internet-gateway"
  }
}

resource "aws_route_table" "redis_route_table" {
  vpc_id = aws_vpc.redis_vpc.id
  tags = {
    Name = "redis-route-table"
  }
}

resource "aws_route" "redis_route_ipv4_internet_access" {
  route_table_id         = aws_route_table.redis_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.redis_internet_gateway.id
}

resource "aws_route" "redis_route_ipv6_internet_access" {
  route_table_id              = aws_route_table.redis_route_table.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.redis_internet_gateway.id
}

resource "aws_route_table_association" "redis_route_table_with_subnet" {
  route_table_id = aws_route_table.redis_route_table.id
  subnet_id      = aws_subnet.redis_subnet.id
}

resource "aws_instance" "redis_server" {
  ami                         = "ami-06d002a0dcaaa385f"
  instance_type               = "t4g.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.redis_security_group.id]
  subnet_id                   = aws_subnet.redis_subnet.id

  root_block_device {
    volume_size = 8
  }

  key_name = aws_key_pair.redis_ssh_key.key_name

  tags = {
    Name = "redis-server"
  }
}

output "ip" {
  value = aws_instance.redis_server.public_ip
}
