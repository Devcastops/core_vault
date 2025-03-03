output "nomad_oidc_client_id" {
  value = vault_identity_oidc_client.nomad.client_id
}

output "nomad_oidc_client_secret" {
  value     = vault_identity_oidc_client.nomad.client_secret
  sensitive = true
}