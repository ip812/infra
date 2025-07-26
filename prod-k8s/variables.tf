variable "org" {
  type = string
}

variable "env" {
  type = string
}

variable "k8s_host" {
  type = string
}

variable "k8s_cluster_ca_certificate" {
  type      = string
  sensitive = true
}

variable "k8s_client_certificate" {
  type      = string
  sensitive = true
}

variable "k8s_client_key" {
  type      = string
  sensitive = true
}

variable "gf_cloud_access_policy_token" {
  type      = string
  sensitive = true
}

variable "ts_client_id" {
  type      = string
  sensitive = true
}

variable "ts_client_secret" {
  type      = string
  sensitive = true
}

variable "ts_api_key" {
  type      = string
  sensitive = true
}

variable "ts_tailnet" {
  type = string
}
