resource "vault_jwt_auth_backend" "core_google" {
  description        = "Auth from google"
  path               = "core/google"
  default_role       = "google"
  type               = "oidc"
  oidc_discovery_url = "https://accounts.google.com"
  oidc_client_id     = var.core_gcp_client_id
  oidc_client_secret = var.core_gcp_client_secret
  tune {
    listing_visibility = "unauth"
    token_type         = "default-service"
    max_lease_ttl      = "768h"
    default_lease_ttl  = "768h"
  }
}

resource "vault_jwt_auth_backend_role" "core_google" {
  backend         = vault_jwt_auth_backend.core_google.path
  role_name       = "google"
  token_policies  = ["default"]
  bound_audiences = [var.core_gcp_client_id]
  oidc_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.user",
    "email"
  ]
  allowed_redirect_uris = [
    "${var.vault_addr}/ui/vault/auth/${vault_jwt_auth_backend.core_google.path}/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
  user_claim            = "email"
  //groups_claim    = "groups"
  role_type = "oidc"
}