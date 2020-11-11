resource "aws_lb" "lb" {
  name               = "lb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.mymodule.security_group_allow_http]
  subnets            = module.mymodule.public_subnet_id.*

  tags = {
    Name = "application-lb"
  }
}

resource "aws_lb_target_group" "lb_target" {
  name     = "lb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.mymodule.vpc_id

   stickiness {
    enabled                  = true
    type                     = "lb_cookie"
    cookie_duration          = 60
  }

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "application-lb-target"
  }
}

resource "aws_lb_target_group_attachment" "tg_attach" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.lb_target.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80

}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target.arn
  }
}



