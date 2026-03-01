variable "region" {
    default = "ca-central-1"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "my_ip" {
  
}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}
variable "alert_email" {}