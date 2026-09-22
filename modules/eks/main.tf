resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-eks"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  tags = {
    Name = "${var.project_name}-eks"
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 10
    min_size     = 3
  }

  tags = {
    Name = "${var.project_name}-node-group"
  }
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}
