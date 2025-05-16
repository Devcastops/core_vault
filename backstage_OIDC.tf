resource "vault_identity_oidc_assignment" "backstage" {
  name = "core_backstage"
  group_ids = [
    vault_identity_group.core_admin.id,
  ]
}

resource "vault_identity_oidc_key" "backstage" {
  name               = "core_backstage"
  algorithm          = "RS256"
  allowed_client_ids = ["*"]
}

resource "vault_identity_oidc_client" "backstage" {
  name = "core_backstage"
  redirect_uris = [
    "http://localhost:7007/api/auth/vault/handler/frame"
  ]
  assignments = [
    vault_identity_oidc_assignment.backstage.name
  ]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_identity_oidc_provider" "backstage" {
  name          = "core_backstage"
  https_enabled = true
  allowed_client_ids = [
    vault_identity_oidc_client.backstage.client_id
  ]
  scopes_supported = [
    vault_identity_oidc_scope.groups.name
  ]
}
