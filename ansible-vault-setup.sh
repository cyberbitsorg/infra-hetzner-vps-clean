#!/usr/bin/env bash
set -euo pipefail

VAULT_PASS_FILE=".vault_pass"
VAULT_FILE="ansible/group_vars/all/vault.yaml"

if [ ! -f "$VAULT_PASS_FILE" ]; then
  read -rsp "Enter vault passphrase: " passphrase
  echo
  echo "$passphrase" > "$VAULT_PASS_FILE"
  chmod 600 "$VAULT_PASS_FILE"
  echo "Created $VAULT_PASS_FILE"
fi

printf "vault_deployacc_sudo_password: %s\n" "$(tofu output -raw deployacc_sudo_password)" > /tmp/vault.tmp
ansible-vault encrypt /tmp/vault.tmp --output "$VAULT_FILE"
rm /tmp/vault.tmp

echo "Vault written to $VAULT_FILE"
