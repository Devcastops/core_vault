resource "vault_identity_entity" "users" {
  for_each = local.members
  name     = each.key
}

resource "vault_identity_entity_alias" "test" {
  for_each       = vault_identity_entity.users
  name           = each.value.name
  mount_accessor = vault_jwt_auth_backend.core_google.accessor
  canonical_id   = each.value.id
}