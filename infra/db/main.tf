locals {
  identifier    = "tier-app"
  vpc_cidr   = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = slice(tolist(data.terraform_remote_state.vpc.outputs.private_subnets), 0, 3)
  db_name = "tierapp"
  db_user = "tierapp"
  password = random_password.password.result
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "tier-postgresql-subnet-group"
  subnet_ids = local.subnet_ids

  tags = {
    Name = "Tier app subnet group"
  }
}

resource "random_password" "password" {
  length   = 10
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.identifier
  description = "PostgreSQL security group"
  vpc_id      = local.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = local.vpc_cidr
    },
  ]
}

resource "aws_ssm_parameter" "ssm_store_password" {
  name     = "${local.identifier}-password"
  value = local.password
  type      = "SecureString"
}

resource "aws_ssm_parameter" "ssm_store_username" {
  name     = "${local.identifier}-username"
  value = local.db_user
  type      = "SecureString"
}


module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.identifier

  engine            = "postgres"
  engine_version    = "14"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = local.db_name
  username = local.db_user
  password = local.password
  port     = "5432"
  
  manage_master_user_password = false

  multi_az = true

  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Owner       = "tierapp"
    Environment = "production"
  }

  # DB subnet group
  subnet_ids           = local.subnet_ids
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name

  # DB parameter group
  family = "postgres14"

  # DB option group
  major_engine_version = "14"

  # Database Deletion Protection
  deletion_protection = true
}
