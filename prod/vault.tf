resource "hcp_service_principal" "k8s_sp" {
  name = "k8s-service-principal"
}

resource "hcp_service_principal_key" "k8s_sp_key" {
  service_principal = hcp_service_principal.k8s_sp.resource_name
}

output "hcp_client_id" {
  value     = hcp_service_principal_key.k8s_sp_key.client_id
  sensitive = true
}

output "hcp_client_secret" {
  value     = hcp_service_principal_key.k8s_sp_key.client_secret
  sensitive = true
}

resource "hcp_project_iam_binding" "k8s_sp_binding" {
  project_id   = var.hcp_project_id
  principal_id = hcp_service_principal.k8s_sp.resource_id
  role         = "roles/viewer"
}
