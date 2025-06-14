output "rabbitmq_public_ip" {
  value = aws_instance.rabbitmq_node.public_ip
}
