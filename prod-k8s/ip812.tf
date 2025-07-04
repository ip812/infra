# resource "kubernetes_namespace" "ip812" {
#   metadata {
#     name = var.org
#   }
# }
# 
# resource "helm_release" "app_pg" {
#   name       = "app-pg"
#   namespace  = kubernetes_namespace.ip812.metadata[0].name
#   chart      = "${path.module}/charts/app-pg"
#   repository = ""
#   version = "0.1.0"
# }
