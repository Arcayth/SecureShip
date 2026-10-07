output "public1_private_dns" {
  value = aws_instance.public_server1.private_dns
}

output "public1_public_ip" {
  value = aws_instance.public_server1.public_ip
}

output "public2_private_dns" {
  value = aws_instance.public_server2.private_dns
}

output "public2_public_ip" {
  value = aws_instance.public_server2.public_ip
}

output "private1_private_dns" {
  value = aws_instance.private_server1.private_dns
}

output "private2_private_dns" {
  value = aws_instance.private_server2.private_dns
}
