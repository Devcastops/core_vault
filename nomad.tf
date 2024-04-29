resource "vault_jwt_auth_backend" "nomad_WI" {
  description        = "Auth from Nomad"
  path               = "core/nomad"
  default_role       = "nomad_WI"
  type               = "jwt"
  jwks_url = "${var.nomad_url}/.well-known/jwks.json"
  jwt_supported_algs = ["RS256", "EdDSA"]

}

resource "vault_jwt_auth_backend_role" "nomad_WI" {
  backend         = vault_jwt_auth_backend.nomad_WI.path
  role_name       = "nomad_WI"
  token_policies  = ["default", vault_policy.core_nomad_wi.name]
  bound_audiences = ["vault.io"]
  oidc_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.user",
    "email"
  ]
  allowed_redirect_uris = ["${var.vault_addr}/ui/vault/auth/${vault_jwt_auth_backend.core_gcp.path}/oidc/callback"]
  user_claim            = "/nomad_job_id"
  //groups_claim    = "groups"
  role_type = "jwt"
  user_claim_json_pointer = true
  claim_mappings = {
    "nomad_namespace": "nomad_namespace",
    "nomad_job_id": "nomad_job_id",
    "nomad_task": "nomad_task"
  }
  token_type = "service"
}