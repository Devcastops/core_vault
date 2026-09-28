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

variable "nomad_addr" {
  type        = string
  description = "url of nomad https://url:4646"
}

variable "consul_url" {
  type        = string
  description = "url of consul https://url:8501"
}

variable "consul_backend_path" {
  type        = string
  description = "The path for the consul backend"
  default     = "core/consul"
}

variable "nomad_wi_shared_engine_depth" {
  type        = number
  description = "Maximum number of \"+\" path segments allowed before the Nomad job identity in the core/nomad/wi policy, for secrets held in shared secrets engines"
  default     = 6
}
