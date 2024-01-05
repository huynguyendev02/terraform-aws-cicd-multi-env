project_name = "huyng14-aps-1-g-petclinic"
project_tag  = "Petclinic-HuyNG14"
owner_tag = "HuyNG14-Terraform"

####NETWORK#####
network_cidr = "10.0.0.0/16"
networks = {
  "public" = {
    subnets = {
      "public-subnet-1" = {
        cidr_block        = "10.0.0.0/20"
        availability_zone = "ap-southeast-1a"
      }
      "public-subnet-2" = {
        cidr_block        = "10.0.16.0/20"
        availability_zone = "ap-southeast-1b"
      }
      "public-subnet-3" = {
        cidr_block        = "10.0.32.0/20"
        availability_zone = "ap-southeast-1c"
      }
    }
  },
  "private" = {
    subnets = {
      "private-subnet-1" = {
        cidr_block        = "10.0.128.0/20"
        availability_zone = "ap-southeast-1a"
      }
      "private-subnet-2" = {
        cidr_block        = "10.0.144.0/20"
        availability_zone = "ap-southeast-1b"
      }
      "private-subnet-3" = {
        cidr_block        = "10.0.160.0/20"
        availability_zone = "ap-southeast-1c"
      }
      "db-subnet-1" = {
        cidr_block        = "10.0.48.0/25"
        availability_zone = "ap-southeast-1a"
      }
      "db-subnet-2" = {
        cidr_block        = "10.0.48.128/25"
        availability_zone = "ap-southeast-1b"
      }
      "db-subnet-3" = {
        cidr_block        = "10.0.49.0/25"
        availability_zone = "ap-southeast-1c"
      }
    }
  }
}
####SECURITY_GROUP_FOR_RDS#####
rds_sg = {
  "inbound"  = {},
  "outbound" = {
    "all" = {
      port        = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
####SECURITY_GROUP_RULE_ACCESS_RDS#####
ec2stg_to_rds_rule = [{
  type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"
}]
fargateprod_to_rds_rule = [{
  type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"
}]
####DATABASE#####
db_instance_storage = 20
db_instance_engine = "mysql"
db_instance_engine_version = "8.0.33"
db_instance_class =  "db.t3.micro"
db_name = "petclinic"
db_username = "petclinic"
backup_retention_period = 0
multi_az = false
storage_encrypted = false
####SECURITY_GROUP_FOR_VPC_ENDPOINT#####
vpce_sg = {
  "inbound"  = {
    "all" = {
      port        = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  },
  "outbound" = {
    "all" = {
      port        = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}