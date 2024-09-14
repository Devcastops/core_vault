resource "vault_policy" "admin" {
  name = "admin"

  policy = <<EOT
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}

resource "vault_policy" "core_terraform_core_vault" {
  name = "core/terraform/core_vault"

  policy = <<EOT
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}

resource "vault_policy" "core_nomad_wi" {
  name = "core/nomad/wi"

  policy = <<EOT
path "{{ identity.entity.aliases.${ vault_jwt_auth_backend.nomad_WI.accessor }.metadata.nomad_job_id }}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_policy" "consul_auto_config" {
  name = "core/consul/auto_config"

  policy = <<EOT
path "identity/oidc/token/${vault_identity_oidc_client.consul_auto_config.name}" {
  capabilities = ["read"]
}
EOT
}
