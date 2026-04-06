resource "vault_auth_backend" "gcp" {
  path = "core/gcp"
  type = "gcp"
}

resource "vault_gcp_auth_backend_role" "client" {
  backend           = vault_auth_backend.gcp.path
  role              = "client"
  type              = "gce"
  bound_projects    = ["devcastops"]
  token_ttl         = 300
  token_max_ttl     = 600
  token_policies    = [vault_policy.consul_server.name, vault_policy.consul_client_token.name]
  add_group_aliases = true
}

resource "vault_gcp_auth_backend_role" "vault_server" {
  backend           = vault_auth_backend.gcp.path
  role              = "vault_server"
  type              = "gce"
  bound_projects    = ["devcastops"]
  bound_labels      = ["vault_server:cluster-0"]
  token_ttl         = 300
  token_max_ttl     = 600
  token_policies    = [vault_policy.ca_rotate.name, vault_policy.consul_client_token.name]
  add_group_aliases = true
}