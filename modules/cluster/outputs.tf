output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnets" {
  value = aws_subnet.private[*].id
}