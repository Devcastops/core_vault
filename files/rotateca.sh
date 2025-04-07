#! /bin/bash


export VAULT_ADDR=https://vault.devcastops.com:8200

vault login -method=oidc -path=core/google > /dev/null

vault delete /pki/issuer/consul

vault write /pki/root/rotate/internal common_name=dc1.consul issuer_name=consul ttl=$((24*8))h