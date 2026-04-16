# ---------------------------------------------------------
# RDS Subnet Group
# - RDSは2つ以上のPrivate Subnetが必須
# - 構成：private_subnet_1a / private_subnet_1c
# ---------------------------------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1c.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}
