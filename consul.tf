resource "vault_consul_secret_backend" "core_consul" {
  path        = "core/consul"
  description = "Manages the Consul backend"

  address = split("://",var.consul_url)[1]
  token   = var.consul_token
  scheme  = split("://",var.consul_url)[0]
}

resource "vault_consul_secret_backend_role" "admin" {
  name    = "admin"
  backend = vault_consul_secret_backend.core_consul.path

  consul_policies = [
    "admin",
  ]
}