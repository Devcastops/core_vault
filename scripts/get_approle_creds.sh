#!/usr/bin/env bash
# Fetch the role ID and a new secret ID for an agent AppRole (see agents.tf)
# and write them to a JSON file.
#
# Usage: get_approle_creds.sh <vault-token> <agent-name> [output-file]
#   vault-token  Vault token with access to core/approle. Pass "-" to be
#                prompted instead (keeps the token out of shell history).
#   agent-name   Agent name from var.agents, e.g. "barn-code" (role "agent-barn-code").
#   output-file  Defaults to ./agent-<agent-name>.json
#
# VAULT_ADDR must be set in the environment.

set -euo pipefail

APPROLE_PATH="core/approle"

usage() {
  sed -n '5,11p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 1
}

[[ $# -lt 2 || $# -gt 3 ]] && usage

token="$1"
agent="$2"
role="agent-${agent}"
out="${3:-./${role}.json}"

if [[ "$token" == "-" ]]; then
  read -rsp "Vault token: " token
  echo >&2
fi

[[ -z "$token" ]] && { echo "Error: empty Vault token." >&2; exit 1; }
[[ -z "${VAULT_ADDR:-}" ]] && { echo "Error: VAULT_ADDR is not set." >&2; exit 1; }

for cmd in vault jq; do
  command -v "$cmd" >/dev/null || { echo "Error: '$cmd' is not installed." >&2; exit 1; }
done

export VAULT_TOKEN="$token"

role_id=$(vault read -field=role_id "auth/${APPROLE_PATH}/role/${role}/role-id")
secret_json=$(vault write -format=json -f "auth/${APPROLE_PATH}/role/${role}/secret-id")

# Create the file with restrictive permissions before writing secrets to it.
umask 077
jq -n \
  --arg role_name "$role" \
  --arg role_id "$role_id" \
  --argjson secret "$secret_json" \
  '{
    role_name: $role_name,
    role_id: $role_id,
    secret_id: $secret.data.secret_id,
    secret_id_accessor: $secret.data.secret_id_accessor,
    secret_id_ttl: $secret.data.secret_id_ttl
  }' > "$out"

echo "Wrote AppRole credentials for ${role} to ${out}" >&2
