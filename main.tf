resource "aws_vpc" "jey_vpc" {
  region     = var.region
  cidr_block = "10.0.0.0/16"


}

resource "aws_subnet" "subnets" {
  for_each   = var.subnet
  cidr_block = each.value
  vpc_id     = aws_vpc.jey_vpc.id
  tags = {
    Name = each.key
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jey_vpc.id
  tags = {
    Name = "igw"
  }

}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.jey_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }

  tags = {
    Name = "public_route_table"

  }

}


resource "aws_route_table_association" "public_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.subnets["public_subnet"].id

}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.jey_vpc.id
  tags = {
    Name = "private_route_table"
  }

}

resource "aws_route_table_association" "private_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.subnets["private_subnet"].id

}

resource "aws_security_group" "public_sg" {
  vpc_id      = aws_vpc.jey_vpc.id
  description = "Allow SSH to bastion host"

  ingress  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "public_sg"
  }

}

resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Allow SSH from Bastion Host"
  vpc_id      = aws_vpc.jey_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private_sg"
  }
}

resource "aws_instance" "servers" {
  for_each = var.servers

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id                   = aws_subnet.subnets[each.value].id
  associate_public_ip_address = each.key == "bastion" ? true : false
  vpc_security_group_ids = [
    each.key == "bastion" ? aws_security_group.public_sg.id : aws_security_group.private_sg.id
  ]
  tags = {
    Name = "${each.key}-server"
  }
}