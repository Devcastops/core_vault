locals {
  agents = { for a in var.agents : a.name => a }
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

  lifecycle {
    precondition {
      condition     = contains(keys(local.members), each.value.owner)
      error_message = "Agent ${each.key} has owner ${each.value.owner}, who is not in local.members."
    }
  }
}

# Agents get their own entities rather than the owner's, which would inherit core/admin.
# AppRole aliases are keyed on the role ID, so logins land on this entity.
resource "vault_identity_entity" "agent" {
  for_each = local.agents
  name     = "agent/${each.key}"
  metadata = {
    owner = each.value.owner
  }
}

resource "vault_identity_entity_alias" "agent" {
  for_each       = vault_approle_auth_backend_role.agent
  name           = each.value.role_id
  mount_accessor = vault_auth_backend.approle.accessor
  canonical_id   = vault_identity_entity.agent[each.key].id
}
