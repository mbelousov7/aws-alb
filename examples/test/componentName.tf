#################################################  <ENV>.tfvars  #################################################
# in the examples for modules, variables are defined and set in the same file as the module definition.
# This is done to better understand the meaning of the variables.
# In a real environment, you should define variables in a variables.tf, the values of variables depending on the environment in the <ENV name>.tfvars
variable "ENV" {
  type        = string
  description = "defines the name of the environment(dev, prod, etc). Should be defined as env variable, for example export TF_VAR_ENV=dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# in example using dev account
variable "account_number" {
  type    = string
  default = "12345678910"
}

variable "labels" {
  default = {
    prefix = "myproject"
    stack  = "stackName"
  }
}

variable "vpc_id" {
  default = "vpc-change-me-123123"
}


variable "subnet_ids" {
  default = ["subnet-1234567890"]
}

variable "cloudteam_policy_names" {
  default = ["cloud-service-policy-global-deny-1", "cloud-service-policy-global-deny-2"]
}

# <ENV>.tfvars end
#################################################################################################################

#################################################  locals vars  #################################################
#if the value of a variable depends on the value of other variables, it should be defined in a locals block

locals {

  lb_count = 1

  labels = merge(
    { env = var.ENV },
    var.labels
  )

  cloudteam_policy_arns = formatlist("arn:aws:iam::${var.account_number}:policy/%s", var.cloudteam_policy_names)

  lb_name = "${var.labels.prefix}-lb-${var.ENV}"
  tg_name = "${var.labels.prefix}-lb-${var.ENV}"

}

#################################################  module config  #################################################
# In module parameters recommend use terraform variables, because:
# - values can be environment dependent
# - this ComponentName.tf file - is more for component logic description, not for values definition
# - it is better to store vars values in one or two places(<ENV>.tfvars file and variables.tf)

module "starmine_api_ecs_task_service_alb_primary" {
  count                = local.lb_count
  source               = "../.."
  load_balancer_name   = local.lb_name
  target_group_name    = local.lb_name
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
  internal             = true
  http_port            = "80"
  target_group_port    = "8080"
  health_check_path    = "/research-analytics/starmine/beta1/actuator/health"
  health_check_matcher = "200"
  labels               = merge(local.labels, { component = "alb-enterprise" }, ) //use alb as component name for better naming
}
