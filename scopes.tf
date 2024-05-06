resource "vault_identity_oidc_scope" "username" {
  name        = "username"
  template    = "{\"username\": {{identity.entity.name}}}"
  description = "Vault OIDC username Scope"
}

resource "vault_identity_oidc_scope" "groups" {
  name        = "groups"
  template    = "{\"groups\":{{identity.entity.groups.names}}}"
  description = "Vault OIDC Groups Scope"
}