resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-ecs"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_ecs_task_definition" "telemetry_worker" {
  family                   = "${var.project_name}-telemetry-worker"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.ecs_task_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "telemetry-worker"
      image     = var.image
      essential = true

      environment = [
        { name = "KAFKA_BOOTSTRAP", value = var.kafka_bootstrap },
        { name = "KINESIS_STREAM", value = var.kinesis_stream }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.project_name}-telemetry-worker"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}-telemetry-worker"
  retention_in_days = 14
}

resource "aws_ecs_service" "telemetry_worker" {
  name            = "${var.project_name}-telemetry-worker"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.telemetry_worker.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    assign_public_ip = false
    security_groups = [var.security_group_id]
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_appautoscaling_target" "ecs_scaling_target" {
  max_capacity       = var.max_count
  min_capacity       = var.min_count
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.telemetry_worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "${var.project_name}-ecs-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60
  }
}
