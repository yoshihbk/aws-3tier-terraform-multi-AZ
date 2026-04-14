# ---------------------------------------------------------
# Application Load Balancer (ALB)
# - Public Subnets に配置
# - ALB SG を適用
# ---------------------------------------------------------
resource "aws_lb" "alb" {
  name               = "web-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id
  ]

  tags = {
    Name = "web-alb"
  }
}
# ---------------------------------------------------------
# Target Group for ALB
# - EC2 (Web/App) をぶら下げる入口
# ---------------------------------------------------------
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "80"
  }

  tags = {
    Name = "web-tg"
  }
}
# ---------------------------------------------------------
# ALB Listener (HTTP :80)
# - 受けたリクエストを Target Group に転送
# ---------------------------------------------------------
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
