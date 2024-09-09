resource "vault_jwt_auth_backend" "core_terraform" {
  path               = "core/terraform"
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

resource "vault_jwt_auth_backend_role" "core_terraform_core_vault" {
  backend        = vault_jwt_auth_backend.core_terraform.path
  role_name      = "core_vault"
  token_policies = ["default", "core/terraform/core_vault"]

  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:devcastops:project:*:workspace:*:run_phase:*"
  }
  user_claim = "terraform_workspace_name"
  role_type  = "jwt"
}