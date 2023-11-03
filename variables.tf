######################################## names, labels, tags ########################################
variable "labels" {
  type = object({
    prefix    = string
    stack     = string
    component = string
    env       = string
  })
  description = "Minimum required map of labels(tags) for creating aws resources"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}

variable "load_balancer_name" {
  type        = string
  default     = ""
  description = "The name for the default load balancer, uses a module label name if left default"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the Security Group will be created."
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to associate with ALB"
}

variable "internal" {
  type        = bool
  default     = true
  description = "A boolean flag to determine whether the ALB should be internal"
}

variable "security_group_enabled" {
  type        = bool
  description = "Enables the security group"
  default     = true
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "A list of additional security group IDs to allow access to ALB"
}

variable "http_port" {
  type        = number
  default     = 80
  description = "The port for the HTTP listener"
}

variable "http_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable HTTP listener"
}

variable "http_ingress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks to allow in HTTP security group"
}

variable "idle_timeout" {
  type        = number
  default     = 60
  description = "The time in seconds that the connection is allowed to be idle"
}

variable "deletion_protection_enabled" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable deletion protection for ALB"
}

variable "target_group_port" {
  type        = number
  default     = 80
  description = "The port for the default target group"
}

variable "target_group_protocol" {
  type        = string
  default     = "HTTP"
  description = "The protocol for the default target group HTTP or HTTPS"
}

variable "target_group_protocol_version" {
  type        = string
  default     = "HTTP1"
  description = "The protocol version for the default target group HTTP1 or HTTP2 or GRPC"
}

variable "target_group_target_type" {
  type        = string
  default     = "ip"
  description = "The type (`instance`, `ip` or `lambda`) of targets that can be registered with the target group"
}

variable "target_group_name" {
  type        = string
  default     = ""
  description = "The name for the default target group, uses a module label name if left default"
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "The destination for the health check request"
}

variable "health_check_port" {
  type        = string
  default     = "traffic-port"
  description = "The port to use for the healthcheck"
}

variable "health_check_protocol" {
  type        = string
  default     = null
  description = "The protocol to use for the healthcheck. If not specified, same as the traffic protocol"
}

variable "health_check_timeout" {
  type        = number
  default     = 10
  description = "The amount of time to wait in seconds before failing a health check request"
}

variable "health_check_healthy_threshold" {
  type        = number
  default     = 2
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
}

variable "health_check_unhealthy_threshold" {
  type        = number
  default     = 2
  description = "The number of consecutive health check failures required before considering the target unhealthy"
}

variable "health_check_interval" {
  type        = number
  default     = 15
  description = "The duration in seconds in between health checks"
}

variable "health_check_matcher" {
  type        = string
  default     = "200-399"
  description = "The HTTP response codes to indicate a healthy check"
}