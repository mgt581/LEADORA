#!/bin/zsh
set -euo pipefail

cd "${0:A:h}/.."

read -s "admin_password?Choose a strong LeadRally administrator password: "
printf '\n'
read -s "admin_password_confirm?Enter it again to confirm: "
printf '\n'

if [[ "$admin_password" != "$admin_password_confirm" ]]; then
  unset admin_password admin_password_confirm
  print -u2 "The passwords did not match. Nothing was changed."
  exit 1
fi
if (( ${#admin_password} < 14 )); then
  unset admin_password admin_password_confirm
  print -u2 "Use at least 14 characters. Nothing was changed."
  exit 1
fi

password_hash="$(LEADRALLY_PASSWORD_INPUT="$admin_password" node -e '
  const { randomBytes, scryptSync } = require("node:crypto");
  const salt = randomBytes(16);
  const hash = scryptSync(process.env.LEADRALLY_PASSWORD_INPUT, salt, 32);
  process.stdout.write(`${salt.toString("base64url")}:${hash.toString("base64url")}`);
')"
unset admin_password admin_password_confirm LEADRALLY_PASSWORD_INPUT

printf '%s' "$password_hash" | npx wrangler secret put LEADRALLY_ADMIN_PASSWORD_HASH
unset password_hash

session_secret="$(openssl rand -base64 48 | tr -d '\n')"
printf '%s' "$session_secret" | npx wrangler secret put LEADRALLY_SESSION_SECRET
unset session_secret

print "LeadRally authentication secrets are configured. You may close this terminal."
