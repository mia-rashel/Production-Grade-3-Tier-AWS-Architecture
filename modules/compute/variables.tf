variable "private_subnets" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "app_sg" {
  description = "App security group ID"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}
variable "db_endpoint" {}
variable "db_username" {}
variable "db_password" {}