#!/usr/bin/env bash
# Log in via OIDC, fetch role_id + a fresh secret_id for an AppRole on core/approle,
# store them, then replace the OIDC token with an AppRole token.
#
# Usage: ./switch-to-approle.sh <agent-name>        (role becomes "agent-<agent-name>")
#   or:  ROLE=agent-foo ./switch-to-approle.sh
#
# Env: VAULT_ADDR (required), OIDC_PATH (default: core/google), OIDC_ROLE (optional),
#      APPROLE_MOUNT (default: core/approle), CRED_FILE (default: ~/.vault-approle)
set -euo pipefail

: "${VAULT_ADDR:?set VAULT_ADDR}"
MOUNT="${APPROLE_MOUNT:-core/approle}"
OIDC_PATH="${OIDC_PATH:-core/google}"
CRED_FILE="${CRED_FILE:-$HOME/.vault-approle}"
ROLE="${ROLE:-${1:+agent-$1}}"
[ -n "${ROLE:-}" ] || { echo "usage: $0 <agent-name> (or set ROLE)" >&2; exit 1; }

command -v vault >/dev/null || { echo "vault CLI not found" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq not found" >&2; exit 1; }

# 1. OIDC login (opens browser); -token-only avoids touching ~/.vault-token yet
echo ">> Logging in via OIDC at auth/${OIDC_PATH}..."
oidc_args=(-method=oidc -path="$OIDC_PATH" -token-only)
[ -n "${OIDC_ROLE:-}" ] && oidc_args+=(role="$OIDC_ROLE")
OIDC_TOKEN="$(vault login "${oidc_args[@]}")"

# 2. Fetch role_id and mint a new secret_id using the OIDC token
echo ">> Fetching credentials for ${MOUNT}/role/${ROLE}..."
ROLE_ID="$(VAULT_TOKEN="$OIDC_TOKEN" vault read -field=role_id "auth/${MOUNT}/role/${ROLE}/role-id")"
SECRET_ID="$(VAULT_TOKEN="$OIDC_TOKEN" vault write -f -field=secret_id "auth/${MOUNT}/role/${ROLE}/secret-id")"

# 3. Persist credentials (0600)
umask 077
cat >"$CRED_FILE" <<EOF
VAULT_ADDR=$VAULT_ADDR
VAULT_APPROLE_MOUNT=$MOUNT
VAULT_ROLE_ID=$ROLE_ID
VAULT_SECRET_ID=$SECRET_ID
EOF
echo ">> Saved to $CRED_FILE"

# 4. Switch: log in with AppRole (writes ~/.vault-token, replacing the OIDC token)
APPROLE_TOKEN="$(vault write -field=token "auth/${MOUNT}/login" role_id="$ROLE_ID" secret_id="$SECRET_ID")"
vault login -no-print "$APPROLE_TOKEN"

# 5. Revoke the OIDC token now that it's no longer needed
VAULT_TOKEN="$OIDC_TOKEN" vault token revoke -self >/dev/null 2>&1 || true

echo ">> Now authenticated as:"
vault token lookup -format=json | jq '{display_name: .data.display_name, policies: .data.policies, ttl: .data.ttl}'
echo ">> Re-login later (secret_id valid ~32d) with:"
echo "   set -a; . $CRED_FILE; set +a; vault login -no-print \$(vault write -field=token auth/\$VAULT_APPROLE_MOUNT/login role_id=\$VAULT_ROLE_ID secret_id=\$VAULT_SECRET_ID)"
