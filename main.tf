locals {
  sg_name = "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-sg-${var.labels.env}"
  alb_name = var.load_balancer_name == "" ? (
    "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-lb-${var.labels.env}"
  ) : var.load_balancer_name
  target_group_name = var.target_group_name == "" ? (
    "${var.labels.prefix}-${var.labels.stack}-${var.labels.component}-tg-${var.labels.env}"
  ) : var.target_group_name
}

resource "aws_security_group" "default" {
  count       = var.security_group_enabled ? 1 : 0
  description = "Controls access to the ALB (HTTP/HTTPS)"
  vpc_id      = var.vpc_id
  name        = local.sg_name
  tags = merge(
    var.labels,
    var.tags,
    { Name = local.sg_name }
  )
}

resource "aws_security_group_rule" "egress" {
  count             = var.security_group_enabled ? 1 : 0
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "http_ingress" {
  count             = var.security_group_enabled && var.http_enabled ? 1 : 0
  type              = "ingress"
  from_port         = var.http_port
  to_port           = var.http_port
  protocol          = "tcp"
  cidr_blocks       = var.http_ingress_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_lb" "default" {
  name               = local.alb_name
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups = compact(
    concat(var.security_group_ids, [join("", aws_security_group.default.*.id)]),
  )
  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.deletion_protection_enabled

  tags = merge(
    var.labels,
    var.tags,
    { Name = local.alb_name }
  )
}

resource "aws_lb_target_group" "default" {
  name             = local.target_group_name
  port             = var.target_group_port
  protocol         = var.target_group_protocol
  protocol_version = var.target_group_protocol_version
  vpc_id           = var.vpc_id
  target_type      = var.target_group_target_type


  health_check {
    protocol            = var.health_check_protocol != null ? var.health_check_protocol : var.target_group_protocol
    path                = var.health_check_path
    port                = var.health_check_port
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  tags = merge(
    var.labels,
    var.tags,
    { Name = local.target_group_name }
  )

}

resource "aws_lb_listener" "http_forward" {
  count             = var.http_enabled ? 1 : 0
  load_balancer_arn = join("", aws_lb.default.*.arn)
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = join("", aws_lb_target_group.default.*.arn)
    type             = "forward"

  }

  tags = merge(
    var.labels,
    var.tags,
  )

}