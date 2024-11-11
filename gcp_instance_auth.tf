resource "vault_auth_backend" "gcp" {
  path = "core/gcp"
  type = "gcp"
}

resource "vault_gcp_auth_backend_role" "client" {
  backend                = vault_auth_backend.gcp.path
  role                   = "client"
  type                   = "gce"
  bound_projects         = ["devcastops"]
  token_ttl              = 300
  token_max_ttl          = 600
  token_policies         = ["core/consul/auto_config"]
  add_group_aliases      = true
}