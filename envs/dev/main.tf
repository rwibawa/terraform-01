terraform {
  required_version = ">= 1.6.0"
}

module "network" {
  source              = "../../modules/network"
  project_name        = var.project_name
  cidr_block          = var.cidr_block
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
}

module "eks" {
  source                = "../../modules/eks"
  project_name          = var.project_name
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = module.network.private_subnet_ids
  cluster_role_arn      = module.iam.eks_cluster_role_arn
  node_role_arn         = module.iam.eks_node_role_arn
}

module "ecs" {
  source             = "../../modules/ecs"
  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  ecs_role_arn       = module.iam.ecs_task_role_arn
}

module "kinesis_kafka" {
  source        = "../../modules/kinesis_kafka"
  project_name  = var.project_name
  shard_count   = var.kinesis_shard_count
}

module "rds" {
  source              = "../../modules/rds"
  project_name        = var.project_name
  vpc_id              = module.network.vpc_id
  private_subnet_ids  = module.network.private_subnet_ids
  db_username         = var.db_username
  db_password         = var.db_password
}

module "redis_cache" {
  source             = "../../modules/redis_cache"
  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
}

module "observability" {
  source        = "../../modules/observability"
  project_name  = var.project_name
  vpc_id        = module.network.vpc_id
  subnet_ids    = module.network.private_subnet_ids
}
