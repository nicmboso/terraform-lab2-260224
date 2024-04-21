
#vpc
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    # Name = "${local.name}-vpc"
    Name = "nic-vpc"
  }
}

#public subnet-1
resource "aws_subnet" "public-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "nic-subnet-pub-1"
    # Name = "${local.name}-pub-subnet"
  }
}

#public subnet-2
resource "aws_subnet" "public-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "nic-subnet-pub-2"
    # Name = "${local.name}-pub-subnet"
  }
}

#private subnet-1
resource "aws_subnet" "private-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "nic-subnet-prv-1"
    # Name = "${local.name}-prv-subnet"
  }
}

#private subnet-2
resource "aws_subnet" "private-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  tags = {
    Name = "nic-subnet-prv-2"
    # Name = "${local.name}-prv-subnet"
  }
}

#igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "nic-igw"
    # Name = "${local.name}-igw"
  }
}

#nat-gw
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "nic-nat"
    # Name = "${local.name}-nat"
  }
}


#elastic IP
resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

#public route table
resource "aws_route_table" "pub-RT" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "nic-pub-RT"
    # Name = "${local.name}-pub-RT"
  }
}

#private route table
resource "aws_route_table" "prv-RT" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "nic-prv-RT"
    # Name = "${local.name}-prv-RT"
  }
}

#public_subnet_1_association
resource "aws_route_table_association" "pubsub-1-Assoc" {
  route_table_id = aws_route_table.pub-RT.id
  subnet_id      = aws_subnet.public-1.id
}

#public_subnet_2_association
resource "aws_route_table_association" "pubsub-2-Assoc" {
  route_table_id = aws_route_table.pub-RT.id
  subnet_id      = aws_subnet.public-2.id
}

#private_subnet_1_association
resource "aws_route_table_association" "prvsub-1-Assoc" {
  route_table_id = aws_route_table.prv-RT.id
  subnet_id      = aws_subnet.private-1.id
}

#private_subnet_2_association
resource "aws_route_table_association" "prvsub-2-Assoc" {
  route_table_id = aws_route_table.prv-RT.id
  subnet_id      = aws_subnet.private-2.id
}

#security group for Bastion Host and instance
#security group for Bastion Host and Ansible
resource "aws_security_group" "ssh-sg" {
  name = "ssh-sg-1"
  # name = "${local.name}-ansible-sg"
  description = "Allow inbound Traffic"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
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
    Name = "ssh-SG"
    # Name = "${local.name}-ansible-sg"
  }
}

#security group for Bastion Host and instance
#security group for Bastion Host and Ansible
resource "aws_security_group" "httpd-sg" {
  name = "httpd-sg-2"
  # name = "${local.name}-httpd-sg"
  description = "Allow inbound Traffic"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "ssh access"
    from_port   = 80
    to_port     = 80
    # from_port   = 22
    # to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    # from_port   = 80
    # to_port     = 80
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "httpd-SG"
    # Name = "${local.name}-httpd-sg"
  }
}

#keypair
resource "aws_key_pair" "keypair" {
  key_name   = "nic-key"
  public_key = file("~/Training/Git/keypairs/nic-key.pub")
}

#ansible instance
resource "aws_instance" "nic-ec2" {
  # resource "aws_instance" "ansible" {
  ami           = "ami-08e592fbb0f535224"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-1.id
  vpc_security_group_ids = [aws_security_group.ssh-sg.id
  , aws_security_group.httpd-sg.id]
  # vpc_security_group_ids = [aws_security_group.ansible-sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keypair.id
  # user_data = local.user_data # needs user_data.tf
  tags = {
    Name = "nic-EC2"
    # Name = "${local.name}-ansible"
  }
}

# #webserver instance
# resource "aws_instance" "web" {
#   ami = "value"
#   instance_type = "t2.micro"
#   subnet_id = aws_subnet.private.id
#   vpc_security_group_ids = [aws_security_group.httpd-sg.id]
#   associate_public_ip_address = true
#   key_name = aws_key_pair.keypair.id
#   # user_data = local.user_data # needs user_data.tf
#   tags = {
#     Name = "nic-webserver"
#     # Name = "${local.name}-webserver"
#   }
# }

# #load balancer for webserver
# resource "aws_elb" "webserver-lb" {
#   name = "nic-webserver-lb"
#   # name = "${local.name}-webserver-lb"
#   subnets = [aws_subnet.public.id]
#   security_groups = [aws_security_group.httpd-sg.id]
#   listener {
#     instance_port = 80
#     instance_protocol = "http"
#     lb_port = 80
#     lb_protocol = "http"
#     }
#   health_check {
#     healthy_threshold = 2
#     unhealthy_threshold = 2
#     timeout = 3
#     target = "TCP:80"
#     interval = 30
#   }
#   instances = [aws_instance.web.id]
#   cross_zone_load_balancing = true
#   idle_timeout = 400
#   connection_draining = true
# }