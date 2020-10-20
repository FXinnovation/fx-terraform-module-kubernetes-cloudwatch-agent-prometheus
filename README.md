# terraform-module-kubernetes-cloudwatch-agent-prometheus

Terraform module that deploys the "prometheus" version of the cloudwatch agent.

## Usage

By default, the agent will send all metrics towards Cloudwatch Logs. You can however select the metrics you want to send to Cloudwatch Metrics by specifying it in the agent configuration. Please refer the ContainerInsights documentation (Link below).

In order for the agent to scrape services and/or pods, the following annotations can be defined:
* `prometheus.io/scrape`: can be `true` or `false`
* `prometheus.io/port`: port number on which to scrape
* `prometheus.io/path`: path on which the metrics are available. Default: `/metrics`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| kubernetes | >= 1.10.0 |
| random | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| kubernetes | >= 1.10.0 |
| random | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| agent\_config\_map\_annotations | Map of annotations that will be applied on the agent\_config\_map. | `map` | `{}` | no |
| agent\_config\_map\_labels | Map of labels that will be applied on the agent\_config\_map. | `map` | `{}` | no |
| agent\_config\_map\_name | Name of the agent\_config\_map. | `string` | `"cloudwatch-agent-prometheus"` | no |
| agent\_configuration | Object representing the agent configuration to be applied. [https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus.html](>> Documentation <<) | `map` | `{}` | no |
| annotations | Map of annotations that will be applied on all the resources. | `map` | `{}` | no |
| ci\_version | Version of the ContainerIsights (must match the image\_version) | `string` | `"k8s/1.2.1-prometheus"` | no |
| cluster\_name | Name of the kubernetes cluster on which the agent runs. (Will be used to identify the origin of the metrics and logs in Cloudwatch) | `string` | n/a | yes |
| cluster\_role\_annotations | Map of annotations that will be applied on the cluster\_role. | `map` | `{}` | no |
| cluster\_role\_binding\_annotations | Map of annotations that will be applied on the cluster\_role. | `map` | `{}` | no |
| cluster\_role\_binding\_labels | Map of labels that will be applied on the cluster\_role. | `map` | `{}` | no |
| cluster\_role\_binding\_name | Name of the cluster\_role. | `string` | `"cloudwatch-agent-prometheus"` | no |
| cluster\_role\_labels | Map of labels that will be applied on the cluster\_role. | `map` | `{}` | no |
| cluster\_role\_name | Name of the cluster\_role. | `string` | `"cloudwatch-agent-prometheus"` | no |
| deployment\_annotations | Map of annotations that will be applied on the deployment. | `map` | `{}` | no |
| deployment\_labels | Map of labels that will be applied on the deployment. | `map` | `{}` | no |
| deployment\_name | Name of the deployment. | `string` | `"cloudwatch-agent-prometheus"` | no |
| deployment\_template\_annotations | Map of annotations that will be applied on the deployment template. | `map` | `{}` | no |
| deployment\_template\_labels | Map of labels that will be applied on the deployment template. | `map` | `{}` | no |
| image | Image to use for the cloudwatch-agent-prometheus. | `string` | `"amazon/cloudwatch-agent"` | no |
| image\_pull\_policy | Pull policy for the image of cloudwatch-agent-prometheus. | `string` | `"Always"` | no |
| image\_version | Image version to use for the cloudwatch-agent-prometheus. | `string` | `"1.248913.0-prometheus"` | no |
| labels | Map of labels that will be applied on all the resources. | `map` | `{}` | no |
| namespace | Name of the namespace in which to deploy the resources. | `string` | `"default"` | no |
| prometheus\_config\_map\_annotations | Map of annotations that will be applied on the prometheus\_config\_map. | `map` | `{}` | no |
| prometheus\_config\_map\_labels | Map of labels that will be applied on the prometheus\_config\_map. | `map` | `{}` | no |
| prometheus\_config\_map\_name | Name of the prometheus\_config\_map. | `string` | `"cloudwatch-prometheus-prometheus"` | no |
| prometheus\_configuration | Object representing the prometheus configuration to be applied. [https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus.html](>> Documentation <<) | `map` | <pre>{<br>  "global": {<br>    "scrape_interval": "1m",<br>    "scrape_timeout": "30s"<br>  },<br>  "scrape_configs": [<br>    {<br>      "job_name": "kubernetes-service-endpoints",<br>      "kubernetes_sd_configs": [<br>        {<br>          "role": "endpoints"<br>        }<br>      ],<br>      "metric_relabel_configs": [<br>        {<br>          "action": "drop",<br>          "regex": "go_gc_duration_seconds.*",<br>          "source_labels": [<br>            "__name__"<br>          ]<br>        }<br>      ],<br>      "relabel_configs": [<br>        {<br>          "action": "keep",<br>          "regex": "true",<br>          "source_labels": [<br>            "__meta_kubernetes_service_annotation_prometheus_io_scrape"<br>          ]<br>        },<br>        {<br>          "action": "replace",<br>          "regex": "(https?)",<br>          "source_labels": [<br>            "__meta_kubernetes_service_annotation_prometheus_io_scheme"<br>          ],<br>          "target_label": "__scheme__"<br>        },<br>        {<br>          "action": "replace",<br>          "regex": "(.+)",<br>          "source_labels": [<br>            "__meta_kubernetes_service_annotation_prometheus_io_path"<br>          ],<br>          "target_label": "__metrics_path__"<br>        },<br>        {<br>          "action": "replace",<br>          "regex": "([^:]+)(?::\\d+)?;(\\d+)",<br>          "replacement": "$1:$2",<br>          "source_labels": [<br>            "__address__",<br>            "__meta_kubernetes_service_annotation_prometheus_io_port"<br>          ],<br>          "target_label": "__address__"<br>        },<br>        {<br>          "action": "labelmap",<br>          "regex": "__meta_kubernetes_service_label_(.+)"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_namespace"<br>          ],<br>          "target_label": "Namespace"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_service"<br>          ],<br>          "target_label": "Service"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_pod_node_name"<br>          ],<br>          "target_label": "kubernetes_node"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_pod_name"<br>          ],<br>          "target_label": "pod_name"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_pod_container_name"<br>          ],<br>          "target_label": "container_name"<br>        }<br>      ],<br>      "sample_limit": 10000<br>    },<br>    {<br>      "job_name": "kubernetes-pods",<br>      "kubernetes_sd_configs": [<br>        {<br>          "role": "pod"<br>        }<br>      ],<br>      "relabel_configs": [<br>        {<br>          "action": "keep",<br>          "regex": "true",<br>          "source_labels": [<br>            "__meta_kubernetes_service_annotation_prometheus_io_scrape"<br>          ]<br>        },<br>        {<br>          "action": "replace",<br>          "regex": "(https?)",<br>          "source_labels": [<br>            "__meta_kubernetes_service_annotation_prometheus_io_scheme"<br>          ],<br>          "target_label": "__scheme__"<br>        },<br>        {<br>          "action": "replace",<br>          "regex": "(.+)",<br>          "source_labels": [<br>            "__meta_kubernetes_service_annotation_prometheus_io_path"<br>          ],<br>          "target_label": "__metrics_path__"<br>        },<br>        {<br>          "action": "replace",<br>          "regex": "([^:]+)(?::\\d+)?;(\\d+)",<br>          "replacement": "$1:$2",<br>          "source_labels": [<br>            "__address__",<br>            "__meta_kubernetes_service_annotation_prometheus_io_port"<br>          ],<br>          "target_label": "__address__"<br>        },<br>        {<br>          "action": "labelmap",<br>          "regex": "__meta_kubernetes_pod_label_(.+)"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_namespace"<br>          ],<br>          "target_label": "Namespace"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_pod_node_name"<br>          ],<br>          "target_label": "kubernetes_node"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_pod_name"<br>          ],<br>          "target_label": "pod_name"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_pod_container_name"<br>          ],<br>          "target_label": "container_name"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_pod_controller_kind"<br>          ],<br>          "target_label": "pod_controller_kind"<br>        },<br>        {<br>          "action": "replace",<br>          "source_labels": [<br>            "__meta_kubernetes_pod_controller_name"<br>          ],<br>          "target_label": "pod_controller_name"<br>        }<br>      ],<br>      "sample_limit": 10000<br>    },<br>    {<br>      "bearer_token_file": "/var/run/secrets/kubernetes.io/serviceaccount/token",<br>      "job_name": "kubernetes-nodes",<br>      "kubernetes_sd_configs": [<br>        {<br>          "role": "node"<br>        }<br>      ],<br>      "relabel_configs": [<br>        {<br>          "action": "labelmap",<br>          "regex": "__meta_kubernetes_node_label_(.+)"<br>        },<br>        {<br>          "replacement": "kubernetes.default.svc:443",<br>          "target_label": "__address__"<br>        },<br>        {<br>          "regex": "(.+)",<br>          "replacement": "/api/v1/nodes/$1/proxy/metrics",<br>          "source_labels": [<br>            "__meta_kubernetes_node_name"<br>          ],<br>          "target_label": "__metrics_path__"<br>        }<br>      ],<br>      "sample_limit": 0,<br>      "scheme": "https",<br>      "tls_config": {<br>        "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"<br>      }<br>    },<br>    {<br>      "bearer_token_file": "/var/run/secrets/kubernetes.io/serviceaccount/token",<br>      "job_name": "kubernetes-nodes-cadvisor",<br>      "kubernetes_sd_configs": [<br>        {<br>          "role": "node"<br>        }<br>      ],<br>      "relabel_configs": [<br>        {<br>          "action": "labelmap",<br>          "regex": "__meta_kubernetes_node_label_(.+)"<br>        },<br>        {<br>          "replacement": "kubernetes.default.svc:443",<br>          "target_label": "__address__"<br>        },<br>        {<br>          "regex": "(.+)",<br>          "replacement": "/api/v1/nodes/$1/proxy/metrics/cadvisor",<br>          "source_labels": [<br>            "__meta_kubernetes_node_name"<br>          ],<br>          "target_label": "__metrics_path__"<br>        }<br>      ],<br>      "sample_limit": 0,<br>      "scheme": "https",<br>      "tls_config": {<br>        "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"<br>      }<br>    }<br>  ]<br>}</pre> | no |
| service\_account\_annotations | Map of annotations that will be applied on the service\_account. | `map` | `{}` | no |
| service\_account\_labels | Map of labels that will be applied on the service\_account. | `map` | `{}` | no |
| service\_account\_name | Name of the service\_account. | `string` | `"cloudwatch-agent-prometheus"` | no |

## Outputs

| Name | Description |
|------|-------------|
| agent\_config\_map | n/a |
| cluster\_role | n/a |
| cluster\_role\_binding | n/a |
| deployment | n/a |
| prometheus\_config\_map | n/a |
| service\_account | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Versioning
This repository follows [Semantic Versioning 2.0.0](https://semver.org/)

## Git Hooks
This repository uses [pre-commit](https://pre-commit.com/) hooks.
