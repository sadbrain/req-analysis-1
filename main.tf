module "vpc" {
  source = "./modules/vpc-6subnets"

  name = "${var.project}-${var.env}"

  vpc_cidr = var.vpc_cidr
  azs      = var.azs

  tags = local.default_tags
}

# Step 2: Security Groups depend on VPC
module "security_groups" {
  source = "./modules/security-groups"

  depends_on = [module.vpc]

  project  = var.project
  env      = var.env
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr

  # Port configurations
  alb_listener_port_fe = var.alb_listener_port_fe
  alb_listener_port_be = var.alb_listener_port_be
  fe_container_port    = var.fe_container_port
  be_container_port    = var.be_container_port
  db_port              = var.db_port
}

# Step 3: NAT Instances depend on VPC and Security Groups
module "nat" {
  source = "./modules/nat"

  depends_on = [module.vpc, module.security_groups]

  project        = var.project
  env            = var.env
  azs            = local.az_names
  vpc_id         = module.vpc.vpc_id
  vpc_cidr       = var.vpc_cidr
  public_subnets = local.public_subnets

  nat_instance_type     = var.nat_instance_type
  nat_security_group_id = module.security_groups.nat_sg_id
  key_name              = var.key_name

  # Route table IDs to update
  private_app_route_table_ids = module.vpc.private_app_route_table_ids
}

# Step 4: ALB depends on VPC and Security Groups (now internal)
module "alb" {
  source = "./modules/alb"

  depends_on = [module.vpc, module.security_groups]

  project             = var.project
  env                 = var.env
  vpc_id              = module.vpc.vpc_id
  private_app_subnets = local.private_app_subnets

  alb_security_group_id   = module.security_groups.alb_sg_id
  alb_listener_port_fe    = var.alb_listener_port_fe
  alb_listener_port_be    = var.alb_listener_port_be
  fe_container_port       = var.fe_container_port
  be_container_port       = var.be_container_port
  alb_healthcheck_path_fe = var.alb_healthcheck_path_fe
  alb_healthcheck_path_be = var.alb_healthcheck_path_be
}

# Step 4.5: S3 bucket for assets (images, PDFs, videos, etc.)
module "s3_assets" {
  source = "./modules/s3"

  project                     = var.project
  env                         = var.env
  cloudfront_distribution_arn = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${module.cloudfront.cloudfront_id}"
}

# Step 4.5: CloudFront with VPC Origin
module "cloudfront" {
  source = "./modules/cloudfront"

  depends_on = [module.alb]

  project                        = var.project
  env                            = var.env
  alb_dns_name                   = module.alb.alb_dns_name
  alb_arn                        = module.alb.alb_arn
  s3_bucket_regional_domain_name = module.s3_assets.bucket_regional_domain_name
  s3_oac_id                      = module.s3_assets.cloudfront_oac_id
  
  # Custom domain and SSL certificate
  domain_names        = ["mixcredevops.online", "green.mixcredevops.online"]
  acm_certificate_arn = var.acm_certificate_id != "" ? "arn:aws:acm:us-east-1:${data.aws_caller_identity.current.account_id}:certificate/${var.acm_certificate_id}" : ""
}

# Step 5: ECS Cluster and IAM (no compute yet)
module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  depends_on = [module.vpc, module.security_groups]

  project    = var.project
  env        = var.env
  aws_region = var.aws_region
}

# Step 6: RDS depends on VPC, Security Groups, and DB subnets
module "rds" {
  source = "./modules/rds"

  depends_on = [module.vpc, module.security_groups]

  project              = var.project
  env                  = var.env
  vpc_id               = module.vpc.vpc_id
  private_db_subnets   = local.private_db_subnets
  db_security_group_id = module.security_groups.db_sg_id

  db_engine                = var.db_engine
  db_engine_version        = var.db_engine_version
  db_instance_class        = var.db_instance_class
  db_allocated_storage     = var.db_allocated_storage
  db_name                  = var.db_name
  db_master_username       = var.db_master_username
  db_master_password       = var.db_master_password
  db_port                  = var.db_port
  db_backup_retention_days = var.db_backup_retention_days
}

# Step 7: ECS Compute (ASG) depends on NAT being ready
module "ecs_compute" {
  source = "./modules/ecs-compute"

  depends_on = [
    module.vpc,
    module.security_groups,
    module.nat,
    module.ecs_cluster
  ]

  project               = var.project
  env                   = var.env
  ecs_cluster_name      = module.ecs_cluster.cluster_name
  ecs_cluster_id        = module.ecs_cluster.cluster_id
  private_app_subnets   = local.private_app_subnets
  ecs_security_group_id = module.security_groups.ecs_sg_id
  key_name              = var.key_name

  ecs_instance_type    = var.ecs_instance_type
  ecs_desired_capacity = var.ecs_desired_capacity
  ecs_min_size         = var.ecs_min_size
  ecs_max_size         = var.ecs_max_size
}

# Step 8: ECS Services depend on everything being ready
module "ecs_services" {
  source = "./modules/ecs-services"

  depends_on = [
    module.ecs_cluster,
    module.ecs_compute,
    module.alb,
    module.rds
  ]

  project        = var.project
  env            = var.env
  aws_region     = var.aws_region
  ecs_cluster_id = module.ecs_cluster.cluster_id

  private_app_subnets   = local.private_app_subnets
  ecs_security_group_id = module.security_groups.ecs_sg_id

  # Task execution role
  ecs_task_execution_role_arn = module.ecs_cluster.task_execution_role_arn
  cloudwatch_log_group_name   = module.ecs_cluster.log_group_name

  # FE configuration
  fe_image            = var.fe_image
  fe_container_port   = var.fe_container_port
  fe_desired_count    = var.fe_desired_count
  fe_target_group_arn = module.alb.fe_target_group_arn

  # BE configuration
  be_image            = var.be_image
  be_container_port   = var.be_container_port
  be_desired_count    = var.be_desired_count
  be_target_group_arn = module.alb.be_target_group_arn
  be_env              = var.be_env

  # RDS connection strings
  db_primary_address = module.rds.primary_address
  db_port            = var.db_port
  db_name            = var.db_name
  db_username        = var.db_master_username
  db_password        = var.db_master_password
}
