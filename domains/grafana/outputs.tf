output "grafana_workspace_url" {
  value = aws_grafana_workspace.workspace_of_portal_grafana.endpoint
}

output "grafana_workspace_id" {
  value = aws_grafana_workspace.workspace_of_portal_grafana.id
}
