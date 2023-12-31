# Terraform AWS Application Load Balancer (ALB)
module "alb" {
  source = "terraform-aws-modules/alb/aws"
  #version = "5.16.0"
  version = "9.4.0"

  name               = "${local.name}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.loadbalancer_sg.security_group_id]

  enable_deletion_protection = false
  listeners = {

    my-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    my-https-listener = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = module.acm.acm_certificate_arn

      # Fixed Response for Root Context       
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed Static message - for Root Context"
        status_code  = "200"
      } # End of Fixed Response

      # Load Balancer Rules
      rules = {

        myapp-rule = {
          priority = 30
          actions = [{
            type = "weighted-forward"
            target_groups = [
              {
                target_group_key = "mytg"
                weight           = 1
              }
            ]
            stickiness = {
              enabled  = true
              duration = 3600
            }
          }]
          conditions = [{
            path_pattern = {
              values = ["/*"]
            }
          }]
        }
    } }
  }

  # Target Groups
  target_groups = {
    mytg = {

      create_attachment                 = false
      name_prefix                       = "mytg-"
      protocol                          = "HTTP"
      port                              = 8080
      target_type                       = "instance"
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = false
      protocol_version                  = "HTTP1"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/login"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      tags = local.common_tags
    }
  }
  tags = local.common_tags
}



resource "aws_lb_target_group_attachment" "mytg" {
  for_each         = { for k, v in module.ec2_private : k => v }
  target_group_arn = module.alb.target_groups["mytg"].arn
  target_id        = each.value.id
  port             = 8080
}


