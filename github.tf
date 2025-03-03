locals {
  github_access = {
    packer_images = {
      policies = ["default", "admin"]
    }
  }
}

resource "vault_jwt_auth_backend" "github_WI" {
  description        = "Auth from github"
  path               = "core/github"
  default_role       = "github_wi"
  type               = "jwt"
  oidc_discovery_url = "https://token.actions.githubusercontent.com"
  bound_issuer       = "https://token.actions.githubusercontent.com"

}

resource "vault_jwt_auth_backend_role" "github_WI" {
  for_each       = local.github_access
  backend        = vault_jwt_auth_backend.github_WI.path
  role_name      = each.key
  token_policies = each.value.policies
  bound_claims = {
    "repository" : "Devcastops/${each.key}"
  }
  user_claim = "actor"
  role_type  = "jwt"
}