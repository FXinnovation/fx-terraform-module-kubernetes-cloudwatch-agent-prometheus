#####
# Locals
#####

locals {
  annotations = {}
  labels      = {}
}

#####
# Randoms
#####

resource "random_string" "selector" {
  special = false
  upper   = false
  number  = false
  length  = 8
}

#####
# Deployment
#####

resource "kubernetes_deployment" "this" {
  metadata {
    name        = var.deployment_name
    namespace   = var.namespace
    annotations = merge(local.annotations, var.annotations, var.deployment_annotations)
    labels      = merge(local.labels, var.labels, var.deployment_labels)
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        selector = random_string.selector.result
      }
    }

    template {
      metadata {
        annotations = merge(local.annotations, var.annotations, var.deployment_template_annotations)
        labels      = merge(local.labels, var.labels, var.deployment_template_labels, { selector = random_string.selector.result })
      }

      spec {
        automount_service_account_token  = true
        service_account_name             = kubernetes_service_account.this.metadata.0.name
        termination_grace_period_seconds = 60

        volume {
          name = "agent-config"

          config_map {
            name = kubernetes_config_map.agent.metadata.0.name
          }
        }

        volume {
          name = "prometheus-config"

          config_map {
            name = kubernetes_config_map.prometheus.metadata.0.name
          }
        }

        container {
          name              = "cloudwatch-agent"
          image             = "${var.image}:${var.image_version}"
          image_pull_policy = var.image_pull_policy

          env {
            name  = "CI_VERSION"
            value = var.ci_version
          }

          resources {
            limits {
              cpu    = "1"
              memory = "1000Mi"
            }

            requests {
              cpu    = "200m"
              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "agent-config"
            mount_path = "/etc/cwagentconfig"
          }

          volume_mount {
            name       = "prometheus-config"
            mount_path = "/etc/prometheusconfig"
          }
        }
      }
    }
  }
}

#####
# RBAC
#####

resource "kubernetes_service_account" "this" {
  metadata {
    name        = var.service_account_name
    namespace   = var.namespace
    annotations = merge(local.annotations, var.annotations, var.service_account_annotations)
    labels      = merge(local.labels, var.labels, var.service_account_labels)
  }
}

resource "kubernetes_cluster_role" "this" {
  metadata {
    name        = var.cluster_role_name
    annotations = merge(local.annotations, var.annotations, var.cluster_role_annotations)
    labels      = merge(local.labels, var.labels, var.cluster_role_labels)
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "services", "endpoints", "pods"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["extensions"]
    resources  = ["ingresses"]
  }

  rule {
    verbs             = ["get"]
    non_resource_urls = ["/metrics"]
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  metadata {
    name        = var.cluster_role_binding_name
    annotations = merge(local.annotations, var.annotations, var.cluster_role_binding_annotations)
    labels      = merge(local.labels, var.labels, var.cluster_role_binding_labels)
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.this.metadata.0.name
    namespace = kubernetes_service_account.this.metadata.0.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.this.metadata.0.name
  }
}

#####
# Config Maps
#####

resource "kubernetes_config_map" "agent" {
  metadata {
    name        = var.agent_config_map_name
    namespace   = var.namespace
    annotations = merge(local.annotations, var.annotations, var.agent_config_map_annotations)
    labels      = merge(local.labels, var.labels, var.agent_config_map_labels)
  }

  data = {
    "cwagentconfig.json" = jsonencode(
      merge(
        var.agent_configuration,
        {
          logs = {
            metrics_collected = {
              prometheus = {
                cluster_name           = var.cluster_name
                log_group_name         = format("/aws/containerinsights/%s/prometheus", var.cluster_name)
                prometheus_config_path = "/etc/prometheusconfig/prometheus.yaml"
              }
            }
          }
        }
      )
    )
  }
}

resource "kubernetes_config_map" "prometheus" {
  metadata {
    name        = var.prometheus_config_map_name
    namespace   = var.namespace
    annotations = merge(local.annotations, var.annotations, var.prometheus_config_map_annotations)
    labels      = merge(local.labels, var.labels, var.prometheus_config_map_labels)
  }

  data = {
    "prometheus.yaml" = jsonencode(var.prometheus_configuration)
  }
}
