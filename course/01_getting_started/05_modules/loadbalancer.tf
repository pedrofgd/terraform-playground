##########################################
# DATA
##########################################

data "aws_elb_service_account" "root" {}

##########################################
# RESOURCES
##########################################

resource "aws_lb" "nginx" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  access_logs {
    bucket  = module.web_app_s3.web_bucket.id
    prefix  = "alb-logs"
    enabled = true
  }

  tags = local.common_tags
}

resource "aws_lb_target_group" "nginx-tg" {
  name     = "${local.name_prefix}-nginx-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  tags = local.common_tags
}

resource "aws_lb_listener" "ngnix-lt" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nginx-lt"
  })

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "ngnix-tga-servers" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.nginx-tg.arn
  target_id        = aws_instance.nginx[count.index].id
  port             = 80
}