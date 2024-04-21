
#ec2 instance
resource "aws_instance" "nic-ec2" {
  ami                         = "ami-08e592fbb0f535224"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keypair.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "nic-instance-1"
  }
}

#keypair
resource "aws_key_pair" "keypair" {
  key_name   = "nic-key"
  public_key = file("~/Training/Git/keypairs/nic-key.pub")
}

#sg
resource "aws_security_group" "sg" {
  name = "nic-sg" #find out diff bw this arg and Name tag
  description = "Allow ssh"
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "nic-sg-1"
  }
}
