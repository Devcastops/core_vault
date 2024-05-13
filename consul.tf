resource "vault_consul_secret_backend" "core_consul" {
  path        = "core/consul"
  description = "Manages the Consul backend"

  address = var.consul_url
  token   = var.consul_token
}

resource "vault_consul_secret_backend_role" "admin" {
  name    = "admin"
  backend = vault_consul_secret_backend.core_consul.path

  consul_policies = [
    "admin",
  ]
}