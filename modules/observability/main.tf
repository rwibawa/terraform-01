resource "aws_prometheus_workspace" "this" {
  alias = "${var.project_name}-amp"
}

resource "aws_grafana_workspace" "this" {
  name = "${var.project_name}-grafana"
  authentication_providers = ["AWS_SSO"]
}

output "prometheus_workspace_id" {
  value = aws_prometheus_workspace.this.id
}

output "grafana_workspace_id" {
  value = aws_grafana_workspace.this.id
}
