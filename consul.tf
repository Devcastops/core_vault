resource "vault_consul_secret_backend" "core_consul" {
  path        = "core/consul"
  description = "Manages the Consul backend"
  address     = split("://", var.consul_url)[1]
  scheme      = split("://", var.consul_url)[0]
  bootstrap   = true
}

resource "vault_consul_secret_backend_role" "terraform" {
  name    = "terraform"
  backend = vault_consul_secret_backend.core_consul.path

  consul_policies = [
    "global-management",
  ]
}

resource "vault_consul_secret_backend_role" "admin" {
  name    = "admin"
  backend = vault_consul_secret_backend.core_consul.path

  consul_roles = [
    "admin",
  ]
}

resource "vault_consul_secret_backend_role" "client" {
  name    = "client"
  backend = vault_consul_secret_backend.core_consul.path

  consul_roles = [
    "admin",
  ]
}

# resource "vault_identity_oidc_assignment" "consul_auto_config" {
#   name       = "core_consul_auto_config"
#   group_ids  = [
#     vault_identity_group.core_admin.id,
#   ]
# }

# resource "vault_identity_oidc_key" "consul_auto_config" {
#   name      = "core_consul_auto_config"
#   algorithm = "RS256"
#   allowed_client_ids = [vault_identity_oidc_client.consul_auto_config.client_id]
# }

# resource "vault_identity_oidc_client" "consul_auto_config" {
#   name          = "consul-cluster-dc1"
#   redirect_uris = [
#   ]
#   assignments = [
#     vault_identity_oidc_assignment.consul_auto_config.name
#   ]
#   key = "core_consul_auto_config"
#   id_token_ttl     = 2400
#   access_token_ttl = 7200
# }

# resource "vault_identity_oidc_provider" "consul_auto_config" {
#   name = "core_consul_auto_config"
#   https_enabled = true
#   allowed_client_ids = [
#     vault_identity_oidc_client.consul_auto_config.client_id
#   ]
#   scopes_supported = [
#   ]
# }

# resource "vault_identity_oidc_role" "consul_auto_config" {
#   name = "consul-cluster-dc1"
#   key = vault_identity_oidc_key.consul_auto_config.name
#   client_id = vault_identity_oidc_client.consul_auto_config.client_id
#   template = "{\"consul\": {\"hostname\": \"consul-client\" } }"
# }