#Create VPC, Subnet, Route Table
module "network" {
  source       = "./modules/network"
  project_name = var.project_name

  network_cidr = var.network_cidr
  networks     = var.networks

  providers = {
    aws = aws.prod
  }
}

#Create SG for RDS
module "rds-security-group" {
  source       = "./modules/security-group"

  create_sg = true
  name = "rds-sg-${var.project_name}"
  description = "Security Group for RDS"
  sg_rules_main = var.rds_sg
  vpc = module.network.vpc

  providers = {
    aws = aws.prod
  }
}
#Allow EC2 in stg access RDS
module "ec2stg-to-rds-security-group-rules" {
  source       = "./modules/security-group"

  create_sg = false
  security_group_id = module.rds-security-group.sg_id
  source_security_group_id = module.stg-ec2-security-group.sg_id
  sg_rules = var.ec2stg_to_rds_rule

  providers = {
    aws = aws.stg
  }
}
#Allow Fargate in prod access RDS
module "fargateprod-to-rds-security-group-rules" {
  source       = "./modules/security-group"

  create_sg = false
  security_group_id = module.rds-security-group.sg_id
  source_security_group_id = module.prod-fargate-security-group.sg_id
  sg_rules = var.fargateprod_to_rds_rule

  providers = {
    aws = aws.prod
  }
}
#Create RDS
module "database" {
  source       = "./modules/database"

  db_subnets_name = "db-subnetgroup-${var.project_name}"
  db_subnets = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "db")]

  db_instance_name = "master-rds-${var.project_name}"
  db_instance_storage = var.db_instance_storage
  db_instance_engine = var.db_instance_engine
  db_instance_engine_version = var.db_instance_engine_version
  db_instance_class =  var.db_instance_class

  db_name = var.db_name
  db_username = var.db_username
  backup_retention_period = var.backup_retention_period
  multi_az = var.multi_az
  db_instance_sg = [module.rds-security-group.sg_id]
  storage_encrypted = var.storage_encrypted

  providers = {
    aws = aws.prod
  }
}
#Create Secret for DB
module "database-secret" {
  source       = "./modules/secretsmanager"

  name = "secret-dbrds-${var.project_name}"
  recovery_window_in_days = 0
  secret_string = jsonencode({
      USERNAME = module.database.rds_master.username
      PASSWORD = module.database.rds_random_password
      ENDPOINT = module.database.rds_master.endpoint
      DB_NAME = module.database.rds_master.db_name
      JDBC_CONNECTION_STRING = "jdbc:mysql://${module.database.rds_master.endpoint}/${module.database.rds_master.db_name}"
  })

  providers = {
    aws = aws.prod
  }
}

#Create SG for VPC Endpoint
module "vpc-endpoint-security-group" {
  source       = "./modules/security-group"

  create_sg = true
  name = "vpce-sg-${var.project_name}"
  description = "Security Group for VPC_Endpoint"
  sg_rules_main = var.vpce_sg
  vpc = module.network.vpc

  providers = {
    aws = aws.prod
  }
}
#Create S3 VPC Endpoint
module "vpc-endpoint-s3" {
  source       = "./modules/vpc-endpoint"

  name = "vpce-s3-${var.project_name}"

  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [module.network.private_route_table.id]
  vpc_id = module.network.vpc.id
  # security_group_ids = [module.vpc-endpoint-security-group.sg_id]
  # private_dns_enabled = true

  depends_on = [ 
    module.network
  ]
  providers = {
    aws = aws.prod
  }
}
#Create ECR VPC Endpoint
module "vpc-endpoint-ecr-api" {
  source       = "./modules/vpc-endpoint"

  name = "vpce-ecr-api-${var.project_name}"

  service_name = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  vpc_id = module.network.vpc.id
  security_group_ids = [module.vpc-endpoint-security-group.sg_id]
  private_dns_enabled = true
  subnet_ids = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "private")]

  depends_on = [ 
    module.network
  ]
  providers = {
    aws = aws.prod
  }
}
module "vpc-endpoint-ecr-dkr" {
  source       = "./modules/vpc-endpoint"

  name = "vpce-ecr-dkr-${var.project_name}"

  service_name = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  vpc_id = module.network.vpc.id
  security_group_ids = [module.vpc-endpoint-security-group.sg_id]
  private_dns_enabled = true
  subnet_ids = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "private")]

  depends_on = [ 
    module.network
  ]
  providers = {
    aws = aws.prod
  }
}
#Create SSM VPC Endpoint
module "vpc-endpoint-ssm" {
  source       = "./modules/vpc-endpoint"

  name = "vpce-ssm-${var.project_name}"

  service_name = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  vpc_id = module.network.vpc.id
  security_group_ids = [module.vpc-endpoint-security-group.sg_id]
  private_dns_enabled = true
  subnet_ids = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "private")]

  depends_on = [ 
    module.network
  ]
  providers = {
    aws = aws.prod
  }
}
#Create Secret Manager VPC Endpoint
module "vpc-endpoint-secrets" {
  source       = "./modules/vpc-endpoint"

  name = "vpce-secrets-${var.project_name}"

  service_name = "com.amazonaws.${var.region}.secretsmanager"
  vpc_endpoint_type = "Interface"
  vpc_id = module.network.vpc.id
  security_group_ids = [module.vpc-endpoint-security-group.sg_id]
  private_dns_enabled = true
  subnet_ids = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "private")]

  depends_on = [ 
    module.network
  ]
  providers = {
    aws = aws.prod
  }
}
#Create CloudWatch Logs VPC Endpoint
module "vpc-endpoint-logs" {
  source       = "./modules/vpc-endpoint"

  name = "vpce-logs-${var.project_name}"

  service_name = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  vpc_id = module.network.vpc.id
  security_group_ids = [module.vpc-endpoint-security-group.sg_id]
  private_dns_enabled = true
  subnet_ids = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "private")]

  depends_on = [ 
    module.network
  ]
  providers = {
    aws = aws.prod
  }
}
#Create CodeDeploy VPC Endpoint
module "vpc-endpoint-codedeploy" {
  source       = "./modules/vpc-endpoint"

  name = "vpce-codedeploy-${var.project_name}"

  service_name = "com.amazonaws.${var.region}.codedeploy"
  vpc_endpoint_type = "Interface"
  vpc_id = module.network.vpc.id
  security_group_ids = [module.vpc-endpoint-security-group.sg_id]
  private_dns_enabled = true
  subnet_ids = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "private")]

  depends_on = [ 
    module.network
  ]
  providers = {
    aws = aws.prod
  }
}
module "vpc-endpoint-codedeploy-command" {
  source       = "./modules/vpc-endpoint"

  name = "vpce-codedeploy-command-${var.project_name}"

  service_name = "com.amazonaws.${var.region}.codedeploy-commands-secure"
  vpc_endpoint_type = "Interface"
  vpc_id = module.network.vpc.id
  security_group_ids = [module.vpc-endpoint-security-group.sg_id]
  private_dns_enabled = true
  subnet_ids = [for subnet in module.network.subnet : subnet.id if strcontains(subnet.tags.Name, "private")]

  depends_on = [ 
    module.network
  ]
  providers = {
    aws = aws.prod
  }
}
module "route53-domain" {
  source  = "./modules/route53"
  project_name = var.project_name

  domain = "huienv.click"
  delegation_set = "N088044219WD0833BH8AG"
}

module "route53-record-primary" {
  source  = "./modules/route53-record"

  hostzone_id = module.route53-domain.zone.zone_id
  name = "huienv.click"
  type = "A"
  set_identifier = "primary"
  failover_routing_policy_type = "PRIMARY"
  health_check_id = module.prod-route53-health-check.health.id


  alias_dns_name = module.prod-alb.lb.dns_name
  alias_zone_id = module.prod-alb.lb.zone_id
}

module "route53-record-secondary" {
  source  = "./modules/route53-record"

  hostzone_id = module.route53-domain.zone.zone_id
  name = "huienv.click"
  type = "A"
  set_identifier = "secondary"
  failover_routing_policy_type = "SECONDARY"
  health_check_id = module.stg-route53-health-check.health.id

  alias_dns_name = module.stg-alb.lb.dns_name
  alias_zone_id = module.stg-alb.lb.zone_id
}

module "route53-record-stg" {
  source  = "./modules/route53-record"

  hostzone_id = module.route53-domain.zone.zone_id
  name = "stg.huienv.click"
  type = "A"
  set_identifier = "primary"
  failover_routing_policy_type = "PRIMARY"


  alias_dns_name = module.stg-alb.lb.dns_name
  alias_zone_id = module.stg-alb.lb.zone_id
}

module "route53-record-prod" {
  source  = "./modules/route53-record"

  hostzone_id = module.route53-domain.zone.zone_id
  name = "prod.huienv.click"
  type = "A"
  set_identifier = "primary"
  failover_routing_policy_type = "PRIMARY"

  alias_dns_name = module.prod-alb.lb.dns_name
  alias_zone_id = module.prod-alb.lb.zone_id
}

module "prod-route53-health-check" {
  source  = "./modules/route53-health"

  fqdn = "prod.huienv.click"
  port = 80
  type = "HTTP"
  resource_path = "/"
  failure_threshold = "3"
  request_interval = "10"
}

module "stg-route53-health-check" {
  source  = "./modules/route53-health"

  fqdn = "stg.huienv.click"
  port = 80
  type = "HTTP"
  resource_path = "/"
  failure_threshold = "3"
  request_interval = "10"
}