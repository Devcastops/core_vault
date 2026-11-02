resource "vault_mount" "nomad_bootstrap" {
  path = "core/nomad"
  type = "kv"
  options = {
    version = "2"
  }
}

resource "vault_jwt_auth_backend" "nomad_WI" {
  description        = "Auth from Nomad"
  path               = "core/nomad"
  default_role       = "nomad_wi"
  type               = "jwt"
  jwks_url           = "${var.nomad_addr}/.well-known/jwks.json"
  jwt_supported_algs = ["RS256", "EdDSA"]

}

resource "vault_jwt_auth_backend_role" "nomad_WI" {
  backend         = vault_jwt_auth_backend.nomad_WI.path
  role_name       = "nomad_wi"
  token_policies  = ["default", vault_policy.core_nomad_wi.name]
  bound_audiences = ["vault.io"]
  oidc_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.user",
    "email"
  ]
  allowed_redirect_uris = ["${var.vault_addr}/ui/vault/auth/${vault_jwt_auth_backend.core_google.path}/oidc/callback"]
  user_claim            = "/nomad_job_id"
  //groups_claim    = "groups"
  role_type               = "jwt"
  user_claim_json_pointer = true
  claim_mappings = {
    "nomad_namespace" : "nomad_namespace",
    "nomad_job_id" : "nomad_job_id",
    "nomad_task" : "nomad_task"
  }
  token_type = "service"
}

data "vault_kv_secret_v2" "nomad_bootstrap" {
  mount = vault_mount.nomad_bootstrap.path
  name  = "bootstrap"
}

resource "vault_nomad_secret_backend" "core_nomad" {
  backend     = var.nomad_backend_path
  description = "Manages the Nomad backend"
  address     = var.nomad_addr
  token       = data.vault_kv_secret_v2.nomad_bootstrap.data["secret_id"]
}

resource "vault_nomad_secret_role" "terraform" {
  backend = vault_nomad_secret_backend.core_nomad.backend
  role    = "terraform"
  type    = "management"
}

resource "vault_nomad_secret_role" "admin" {
  backend  = vault_nomad_secret_backend.core_nomad.backend
  role     = "admin"
  type     = "client"
  policies = ["admin"]
}

resource "vault_nomad_secret_role" "core_read" {
  backend  = vault_nomad_secret_backend.core_nomad.backend
  role     = "core_read"
  type     = "client"
  policies = ["read_only"]
}
