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
path "{{ identity.entity.aliases.${vault_jwt_auth_backend.nomad_WI.accessor}.metadata.nomad_job_id }}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "{{ identity.entity.aliases.${vault_jwt_auth_backend.nomad_WI.accessor}.metadata.nomad_namespace }}/{{ identity.entity.aliases.${vault_jwt_auth_backend.nomad_WI.accessor}.metadata.nomad_job_id }}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT
}

resource "vault_policy" "consul_server" {
  name = "core/consul/server"

  policy = <<EOT
path "${vault_mount.pki.path}/*" {
  capabilities = ["read", "list"]
}
path "${vault_mount.pki.path}/issue/${vault_pki_secret_backend_role.role.name}" {
  capabilities = ["read", "create", "list"]
}
path "${vault_mount.pki.path}/sign/${vault_pki_secret_backend_role.role.name}" {
  capabilities = ["read", "create", "list"]
}
EOT
}
