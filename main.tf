provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "rabbitmq-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "rabbitmq-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "rabbitmq_sg" {
  name        = "rabbitmq-sg"
  description = "Allow RabbitMQ ports"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rabbitmq-sg"
  }
}

resource "aws_instance" "rabbitmq_node" {
  ami           = "ami-053b0d53c279acc90" # Ubuntu 22.04
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.rabbitmq_sg.id]

  user_data = file("user_data.sh")

  tags = {
    Name = "rabbitmq-node"
  }
}


resource "tls_private_key" "rabbitmq_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "rabbitmq_key" {
  key_name   = "rabbitmq-key"
  public_key = tls_private_key.rabbitmq_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.rabbitmq_key.private_key_pem
  filename = "${path.module}/rabbitmq-key.pem"
  file_permission = "0400"
}
