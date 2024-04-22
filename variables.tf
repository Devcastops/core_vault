variable "vault_addr" {
  type        = string
  description = "The address for the vault cluster"
}

variable "core_gcp_client_id" {
  sensitive   = true
  type        = string
  description = "The client id for gpc auth"
}

variable "core_gcp_client_secret" {
  sensitive   = true
  type        = string
  description = "The client secret for gpc auth"
}

variable "nomad_url" {
  type = string
  description = "url of nomad https://url:4646"
}