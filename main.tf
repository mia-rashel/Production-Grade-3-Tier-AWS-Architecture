module "network" {
  source   = "./modules/network"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source  = "./modules/security"
  vpc_id  = module.network.vpc_id
  my_ip   = var.my_ip
}

module "database" {
  source          = "./modules/database"
  private_subnets = module.network.private_db_subnets
  db_sg           = module.security.db_sg
  db_username     = var.db_username
  db_password     = var.db_password
}

module "loadbalancer" {
  source         = "./modules/loadbalancer"
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets
  alb_sg         = module.security.alb_sg
}

module "compute" {
  source            = "./modules/compute"
  private_subnets   = module.network.private_subnets
  app_sg            = module.security.app_sg
  target_group_arn  = module.loadbalancer.target_group_arn
  db_endpoint       = module.database.db_endpoint
    db_username = var.db_username
  db_password = var.db_password
}

module "monitoring" {
  source      = "./modules/monitoring"
  alert_email = var.alert_email
  asg_name    = module.compute.asg_name
}