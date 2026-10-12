output "public1_private_dns" {
  value = aws_instance.public_server1.private_dns
}

output "public1_public_ip" {
  value = aws_instance.public_server1.public_ip
}

output "private1_private_dns" {
  value = aws_instance.private_server1.private_dns
}
