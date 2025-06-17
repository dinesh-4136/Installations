#!/bin/bash

# === START VAULT DEV SERVER ===
echo "Starting Vault in dev mode..."

# Kill any existing Vault server
pkill vault 2>/dev/null

# Start a new dev server and capture the root token
VAULT_DEV_LOG="vault.log"
nohup vault server -dev > "$VAULT_DEV_LOG" 2>&1 &
sleep 3

# Extract the root token from the dev server log
VAULT_TOKEN=$(grep -m 1 'Root Token:' "$VAULT_DEV_LOG" | awk '{print $NF}')
export VAULT_TOKEN
export VAULT_ADDR="http://127.0.0.1:8200"

echo "✅ Vault is running at $VAULT_ADDR"
echo "🔐 Vault Token: $VAULT_TOKEN"

# === ENABLE KV SECRETS ENGINE (v2) ===
vault secrets enable -path=awscreds kv-v2 || echo "🔁 KV engine already enabled."

# === STORE AWS IAM CREDENTIALS IN VAULT ===
AWS_ACCESS_KEY="<Access_Key>"          # === <Access_Key> Replace with AWS access key ===
AWS_SECRET_KEY="<Secret_Access_Key>"   # === <Secret_Access_Key> Replace AWS secret access key ===

vault kv put awscreds/terraform \
  AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY" \
  AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY"

# === VERIFY VAULT ENTRY ===
echo "✅ Stored AWS credentials. Retrieving:"
vault kv get awscreds/terraform

# === use fixed token every time ===
vault server -dev -dev-root-token-id="root"

# === Export the Token ===
export VAULT_TOKEN=root
