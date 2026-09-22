resource "aws_kinesis_stream" "telemetry" {
  name        = "${var.project_name}-telemetry"
  shard_count = var.shard_count
  retention_period = 24
  tags = {
    Name = "${var.project_name}-telemetry"
  }
}

# If using MSK (Kafka)
resource "aws_msk_cluster" "kafka" {
  cluster_name           = "${var.project_name}-kafka"
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    client_subnets  = var.private_subnet_ids
    security_groups = [var.security_group_id]
  }

  tags = {
    Name = "${var.project_name}-kafka"
  }
}

output "kinesis_stream_name" {
  value = aws_kinesis_stream.telemetry.name
}

output "kafka_bootstrap_brokers" {
  value = aws_msk_cluster.kafka.bootstrap_brokers
}
