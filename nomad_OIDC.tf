resource "vault_identity_oidc_assignment" "nomad" {
  name       = "core_nomad"
  group_ids  = [
    vault_identity_group.core_admin.id,
  ]
}

resource "vault_identity_oidc_key" "nomad" {
  name      = "core_nomad"
  algorithm = "RS256"
  allowed_client_ids = ["*"]
}

resource "vault_identity_oidc_client" "nomad" {
  name          = "core_nomad"
  redirect_uris = [
    "https://nomad.devcastops.com:4649/oidc/callback",
    "https://nomad.devcastops.com:4200/ui/settings/tokens"
  ]
  assignments = [
    vault_identity_oidc_assignment.nomad.name
  ]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}