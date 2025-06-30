# resource "helm_release" "grafana_k8s_monitoring" {
#   name             = "grafana-k8s-monitoring"
#   repository       = "https://grafana.github.io/helm-charts"
#   chart            = "k8s-monitoring"
#   version          = "2.1.4"
#   namespace        = ""
#   create_namespace = true
#   wait             = false
#   timeout          = 600
# }
