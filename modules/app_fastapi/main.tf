resource "helm_release" "fastapi_ws" {
  name       = "${var.project_name}-fastapi-ws"
  namespace  = var.namespace

  repository = var.helm_repo
  chart      = var.helm_chart
  version    = var.chart_version

  create_namespace = true

  values = [
    yamlencode({
      replicaCount = var.replicas

      image = {
        repository = var.image_repo
        tag        = var.image_tag
        pullPolicy = "IfNotPresent"
      }

      service = {
        type = "LoadBalancer"
        port = 80
      }

      env = [
        { name = "KAFKA_BOOTSTRAP", value = var.kafka_bootstrap },
        { name = "KINESIS_STREAM",  value = var.kinesis_stream },
        { name = "REDIS_ENDPOINT",  value = var.redis_endpoint },
        { name = "LOG_LEVEL",       value = var.log_level }
      ]

      resources = {
        requests = {
          cpu    = var.cpu_request
          memory = var.memory_request
        }
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      autoscaling = {
        enabled = var.autoscaling_enabled
        minReplicas = var.autoscaling_min
        maxReplicas = var.autoscaling_max
        targetCPUUtilizationPercentage = var.autoscaling_cpu_target
      }

      websocket = {
        enabled = true
        path    = "/ws"
      }

      nodeSelector = var.node_selector
      tolerations  = var.tolerations
      affinity     = var.affinity
    })
  ]
}
