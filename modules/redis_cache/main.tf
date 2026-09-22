resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Project = var.project_name
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id        = "${var.project_name}-redis"
  engine            = "redis"
  node_type         = var.node_type
  num_cache_nodes   = var.num_nodes
  subnet_group_name = aws_elasticache_subnet_group.this.name
  port              = 6379

  tags = {
    Project = var.project_name
  }
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}
