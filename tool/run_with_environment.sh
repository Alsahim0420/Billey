#!/usr/bin/env bash
set -euo pipefail

key_file=".env.encryption.key"
encrypted_asset="assets/config/environment.enc"

if [[ ! -f "$key_file" ]]; then
  echo "Falta $key_file. Genera una clave Base64 de 32 bytes." >&2
  exit 1
fi

if [[ ! -f "$encrypted_asset" ]]; then
  echo "Falta $encrypted_asset. Ejecuta tool/encrypt_environment.dart." >&2
  exit 1
fi

environment_key="$(tr -d '\r\n' < "$key_file")"

flutter run \
  --dart-define=ENV_ENCRYPTION_KEY="$environment_key" \
  "$@"
