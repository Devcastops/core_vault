resource "vault_identity_group" "core_admin" {
  name     = "core/admin"
  type     = "internal"
  policies = ["admin"]
  member_entity_ids = [for s in keys(local.members) : vault_identity_entity.users[s].id if contains(local.members[s].groups,"core/admin")]
}