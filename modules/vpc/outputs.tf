output "vpc_id" {
  value = aws_vpc.main.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

# --- Старі назви (для сумісності з EKS) ---
output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

# --- Нові назви (для модуля RDS) ---
# Ми просто дублюємо ті самі дані під новими іменами, 
# щоб main.tf міг їх знайти.

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}