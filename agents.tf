locals {
  agents = { for a in var.agents : a.name => a }
}

resource "vault_identity_entity" "bot" {
  for_each  = local.agents
  name      = each.key
  policies  = []
  metadata  = {
    owner = each.value.owner
  }
}

resource "vault_identity_entity_alias" "bot" {
  for_each        = local.agents
  name            = each.key
  mount_accessor  = vault_auth_backend.approle.accessor
  canonical_id    = vault_identity_entity.bot[each.key].id
}



resource "vault_auth_backend" "approle" {
  path        = "core/approle"
  type        = "approle"
  description = "Auth for agents acting on behalf of members"
}

resource "vault_approle_auth_backend_role" "agent" {
  for_each       = local.agents
  backend        = vault_auth_backend.approle.path
  role_name      = "agent-${each.key}"
  token_policies = [vault_policy.nomad_core_read.name, vault_policy.consul_core_read.name]
  token_ttl      = 60 * 60
  token_max_ttl  = 4 * 60 * 60
  secret_id_ttl  = 32 * 24 * 60 * 60
  role_id        = each.key
  lifecycle {
    precondition {
      condition     = contains(keys(local.members), each.value.owner)
      error_message = "Agent ${each.key} has owner ${each.value.owner}, who is not in local.members."
    }
  }
}

resource "vault_identity_mfa_duo" "this" {
  api_hostname    = "api-63ccd50a.duosecurity.com"
  secret_key      = var.duo_secret_key
  integration_key = var.duo_integration_key
  username_format = "{{identity.entity.metadata.owner}}"
}

resource "vault_identity_mfa_login_enforcement" "approle" {
  name = "approle"
  mfa_method_ids = [
    vault_identity_mfa_duo.this.method_id,
  ]
  auth_method_accessors = [vault_auth_backend.approle.accessor]
}