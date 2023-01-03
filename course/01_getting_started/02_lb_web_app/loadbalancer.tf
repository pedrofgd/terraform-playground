resource "aws_lb" "nginx" {
  name               = "terraform-playground-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false

  tags = local.common_tags
}

resource "aws_lb_target_group" "nginx-tg" {
  name     = "nginx-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  tags = local.common_tags
}

resource "aws_lb_listener" "ngnix-lt" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"

  tags = local.common_tags

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "ngnix-tga-server1" {
  target_group_arn = aws_lb_target_group.nginx-tg.arn
  target_id        = aws_instance.nginx1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ngnix-tga-server2" {
  target_group_arn = aws_lb_target_group.nginx-tg.arn
  target_id        = aws_instance.nginx2.id 
  port             = 80
}