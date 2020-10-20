output "deployment" {
  value = kubernetes_deployment.this
}

output "service_account" {
  value = kubernetes_service_account.this
}

output "cluster_role" {
  value = kubernetes_cluster_role.this
}

output "cluster_role_binding" {
  value = kubernetes_cluster_role_binding.this
}

output "agent_config_map" {
  value = kubernetes_config_map.agent
}

output "prometheus_config_map" {
  value = kubernetes_config_map.prometheus
}
