locals {
  # "james.sandford@blinkbyte.co.uk" -> "james-sandford"; AppRole names cannot contain "@"
  agents = { for email in keys(local.members) : email => replace(split("@", email)[0], ".", "-") }
}

resource "vault_auth_backend" "approle" {
  path        = "core/approle"
  type        = "approle"
  description = "Auth for agents acting on behalf of members"
}

# Agents get their own entities rather than the member's, which would inherit core/admin
resource "vault_approle_auth_backend_role" "agent" {
  for_each       = local.agents
  backend        = vault_auth_backend.approle.path
  role_name      = "agent-${each.value}"
  token_policies = [vault_policy.nomad_core_read.name, vault_policy.consul_core_read.name]
  token_ttl      = 60 * 60
  token_max_ttl  = 4 * 60 * 60
  secret_id_ttl  = 32 * 24 * 60 * 60
}
