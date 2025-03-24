resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "Vault PKI mount to act as internal CA"

  default_lease_ttl_seconds = 31 * 24 * 60 * 60
  max_lease_ttl_seconds     = 31 * 24 * 60 * 60
}

resource "vault_pki_secret_backend_root_cert" "consul" {
  backend              = vault_mount.pki.path
  type                 = "internal"
  common_name          = "dc1.consul"
  ttl                  = "315360000"
  format               = "pem"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = false
  ou                   = "DevCastOps"
  organization         = "DevCastOps"
  issuer_name          = "consul"
  lifecycle {
    ignore_changes = [issuer_id]
  }
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "consul"
  ttl              = 31 * 24 * 60 * 60
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["dc1.consul"]
  allow_subdomains = true
  generate_lease   = true
}