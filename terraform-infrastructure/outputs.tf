output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.dream_vpc.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.dream_subnet.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.dream_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.dream_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.dream_instance.public_dns
}
