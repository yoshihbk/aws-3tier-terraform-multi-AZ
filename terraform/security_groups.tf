# ---------------------------------------------------------
# Security Group for ALB
# - インターネットからの HTTP/HTTPS を受け付ける外部公開用 SG
# - EC2 へはこの SG からのみ通信を許可する（ゼロトラスト設計）
# ---------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security Group for ALB"
  vpc_id      = aws_vpc.main.id

  # -------------------------------------------------------
  # Inbound Rules
  # -------------------------------------------------------

  # HTTP (80) - 全世界からアクセス可能
  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (443) - 全世界からアクセス可能
  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # -------------------------------------------------------
  # Outbound Rules
  # - ALB → EC2 への通信は ALB が自動で行うため全許可で問題なし
  # -------------------------------------------------------
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}


# ---------------------------------------------------------
# Security Group for EC2 (Web/App)
# - ALB からの HTTP(80) のみ受け付ける
# - インターネットからの直接アクセスは禁止（ゼロトラスト）
# - SSH(22) は不要（SSM Session Manager を使用）
# ---------------------------------------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Security Group for EC2 instances"
  vpc_id      = aws_vpc.main.id

  # -------------------------------------------------------
  # Inbound Rules
  # -------------------------------------------------------

  # HTTP (80) - ALB からのみ許可
  ingress {
    description     = "Allow HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # -------------------------------------------------------
  # Outbound Rules
  # - NAT Gateway 経由で外部へ出るため全許可で問題なし
  # -------------------------------------------------------
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}
