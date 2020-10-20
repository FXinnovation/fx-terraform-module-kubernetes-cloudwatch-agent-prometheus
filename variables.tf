#####
# Global
#####

variable "namespace" {
  description = "Name of the namespace in which to deploy the resources."
  default     = "default"
}

variable "annotations" {
  description = "Map of annotations that will be applied on all the resources."
  default     = {}
}

variable "labels" {
  description = "Map of labels that will be applied on all the resources."
  default     = {}
}

#####
# Application
#####

variable "image" {
  description = "Image to use for the cloudwatch-agent-prometheus."
  default     = "amazon/cloudwatch-agent"
}

variable "image_version" {
  description = "Image version to use for the cloudwatch-agent-prometheus."
  default     = "1.248913.0-prometheus"
}

variable "image_pull_policy" {
  description = "Pull policy for the image of cloudwatch-agent-prometheus."
  default     = "Always"
}

variable "ci_version" {
  description = "Version of the ContainerIsights (must match the image_version)"
  default     = "k8s/1.2.1-prometheus"
}

variable "cluster_name" {
  description = "Name of the kubernetes cluster on which the agent runs. (Will be used to identify the origin of the metrics and logs in Cloudwatch)"
  type        = string
}

variable "agent_configuration" {
  description = "Object representing the agent configuration to be applied. [https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus.html](>> Documentation <<)"
  default     = {}
}

variable "prometheus_configuration" {
  description = "Object representing the prometheus configuration to be applied. [https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus.html](>> Documentation <<)"
  default = {
    global = {
      scrape_interval = "1m"
      scrape_timeout  = "30s"
    }
    scrape_configs = [
      {
        job_name     = "kubernetes-service-endpoints"
        sample_limit = 10000
        kubernetes_sd_configs = [
          {
            role = "endpoints"
          }
        ]
        relabel_configs = [
          {
            source_labels = ["__meta_kubernetes_service_annotation_prometheus_io_scrape"]
            action        = "keep"
            regex         = "true"
          },
          {
            source_labels = ["__meta_kubernetes_service_annotation_prometheus_io_scheme"]
            action        = "replace"
            target_label  = "__scheme__"
            regex         = "(https?)"
          },
          {
            source_labels = ["__meta_kubernetes_service_annotation_prometheus_io_path"]
            action        = "replace"
            target_label  = "__metrics_path__"
            regex         = "(.+)"
          },
          {
            source_labels = ["__address__", "__meta_kubernetes_service_annotation_prometheus_io_port"]
            action        = "replace"
            target_label  = "__address__"
            regex         = "([^:]+)(?::\\d+)?;(\\d+)"
            replacement   = "$1:$2"
          },
          {
            action = "labelmap"
            regex  = "__meta_kubernetes_service_label_(.+)"
          },
          {
            source_labels = ["__meta_kubernetes_namespace"]
            action        = "replace"
            target_label  = "Namespace"
          },
          {
            source_labels = ["__meta_kubernetes_service"]
            action        = "replace"
            target_label  = "Service"
          },
          {
            source_labels = ["__meta_kubernetes_pod_node_name"]
            action        = "replace"
            target_label  = "kubernetes_node"
          },
          {
            source_labels = ["__meta_kubernetes_pod_name"]
            action        = "replace"
            target_label  = "pod_name"
          },
          {
            source_labels = ["__meta_kubernetes_pod_container_name"]
            action        = "replace"
            target_label  = "container_name"
          },
        ]
        metric_relabel_configs = [
          {
            source_labels = ["__name__"]
            regex         = "go_gc_duration_seconds.*"
            action        = "drop"
          }
        ]
      },
      {
        job_name     = "kubernetes-pods"
        sample_limit = 10000
        kubernetes_sd_configs = [
          {
            role = "pod"
          }
        ]
        relabel_configs = [
          {
            source_labels = ["__meta_kubernetes_service_annotation_prometheus_io_scrape"]
            action        = "keep"
            regex         = "true"
          },
          {
            source_labels = ["__meta_kubernetes_service_annotation_prometheus_io_scheme"]
            action        = "replace"
            target_label  = "__scheme__"
            regex         = "(https?)"
          },
          {
            source_labels = ["__meta_kubernetes_service_annotation_prometheus_io_path"]
            action        = "replace"
            target_label  = "__metrics_path__"
            regex         = "(.+)"
          },
          {
            source_labels = ["__address__", "__meta_kubernetes_service_annotation_prometheus_io_port"]
            action        = "replace"
            target_label  = "__address__"
            regex         = "([^:]+)(?::\\d+)?;(\\d+)"
            replacement   = "$1:$2"
          },
          {
            action = "labelmap"
            regex  = "__meta_kubernetes_pod_label_(.+)"
          },
          {
            source_labels = ["__meta_kubernetes_namespace"]
            action        = "replace"
            target_label  = "Namespace"
          },
          {
            source_labels = ["__meta_kubernetes_pod_node_name"]
            action        = "replace"
            target_label  = "kubernetes_node"
          },
          {
            source_labels = ["__meta_kubernetes_pod_name"]
            action        = "replace"
            target_label  = "pod_name"
          },
          {
            source_labels = ["__meta_kubernetes_pod_container_name"]
            action        = "replace"
            target_label  = "container_name"
          },
          {
            source_labels = ["__meta_kubernetes_pod_controller_kind"]
            action        = "replace"
            target_label  = "pod_controller_kind"
          },
          {
            source_labels = ["__meta_kubernetes_pod_controller_name"]
            action        = "replace"
            target_label  = "pod_controller_name"
          },
        ]
      },
      {
        job_name     = "kubernetes-nodes"
        sample_limit = 0
        scheme       = "https"
        tls_config = {
          ca_file = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        }
        bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
        kubernetes_sd_configs = [
          {
            role = "node"
          },
        ]
        relabel_configs = [
          {
            action = "labelmap"
            regex  = "__meta_kubernetes_node_label_(.+)"
          },
          {
            target_label = "__address__"
            replacement  = "kubernetes.default.svc:443"
          },
          {
            source_labels = ["__meta_kubernetes_node_name"]
            regex         = "(.+)"
            target_label  = "__metrics_path__"
            replacement   = "/api/v1/nodes/$1/proxy/metrics"
          },
        ]
      },
      {
        job_name     = "kubernetes-nodes-cadvisor"
        sample_limit = 0
        scheme       = "https"
        tls_config = {
          ca_file = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
        }
        bearer_token_file = "/var/run/secrets/kubernetes.io/serviceaccount/token"
        kubernetes_sd_configs = [
          {
            role = "node"
          },
        ]
        relabel_configs = [
          {
            action = "labelmap"
            regex  = "__meta_kubernetes_node_label_(.+)"
          },
          {
            target_label = "__address__"
            replacement  = "kubernetes.default.svc:443"
          },
          {
            source_labels = ["__meta_kubernetes_node_name"]
            regex         = "(.+)"
            target_label  = "__metrics_path__"
            replacement   = "/api/v1/nodes/$1/proxy/metrics/cadvisor"
          },
        ]
      },
    ]
  }
}

#####
# Deployment
#####

variable "deployment_name" {
  description = "Name of the deployment."
  default     = "cloudwatch-agent-prometheus"
}

variable "deployment_annotations" {
  description = "Map of annotations that will be applied on the deployment."
  default     = {}
}

variable "deployment_template_annotations" {
  description = "Map of annotations that will be applied on the deployment template."
  default     = {}
}

variable "deployment_labels" {
  description = "Map of labels that will be applied on the deployment."
  default     = {}
}

variable "deployment_template_labels" {
  description = "Map of labels that will be applied on the deployment template."
  default     = {}
}

#####
# RBAC
#####

variable "service_account_name" {
  description = "Name of the service_account."
  default     = "cloudwatch-agent-prometheus"
}

variable "service_account_annotations" {
  description = "Map of annotations that will be applied on the service_account."
  default     = {}
}

variable "service_account_labels" {
  description = "Map of labels that will be applied on the service_account."
  default     = {}
}

variable "cluster_role_name" {
  description = "Name of the cluster_role."
  default     = "cloudwatch-agent-prometheus"
}

variable "cluster_role_annotations" {
  description = "Map of annotations that will be applied on the cluster_role."
  default     = {}
}

variable "cluster_role_labels" {
  description = "Map of labels that will be applied on the cluster_role."
  default     = {}
}

variable "cluster_role_binding_name" {
  description = "Name of the cluster_role."
  default     = "cloudwatch-agent-prometheus"
}

variable "cluster_role_binding_annotations" {
  description = "Map of annotations that will be applied on the cluster_role."
  default     = {}
}

variable "cluster_role_binding_labels" {
  description = "Map of labels that will be applied on the cluster_role."
  default     = {}
}

#####
# Config Map
#####

variable "agent_config_map_name" {
  description = "Name of the agent_config_map."
  default     = "cloudwatch-agent-prometheus"
}

variable "agent_config_map_annotations" {
  description = "Map of annotations that will be applied on the agent_config_map."
  default     = {}
}

variable "agent_config_map_labels" {
  description = "Map of labels that will be applied on the agent_config_map."
  default     = {}
}

variable "prometheus_config_map_name" {
  description = "Name of the prometheus_config_map."
  default     = "cloudwatch-prometheus-prometheus"
}

variable "prometheus_config_map_annotations" {
  description = "Map of annotations that will be applied on the prometheus_config_map."
  default     = {}
}

variable "prometheus_config_map_labels" {
  description = "Map of labels that will be applied on the prometheus_config_map."
  default     = {}
}
