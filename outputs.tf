output "nomad_oidc_client_id" {
  value = vault_identity_oidc_client.nomad.id
}