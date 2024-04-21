output "instance-ip" {
  value = aws_instance.nic-ec2.public_ip
}