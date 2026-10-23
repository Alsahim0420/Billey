#!/usr/bin/env bash
set -euo pipefail
if [[ ! -f assets/config/environment.enc ]]; then
  echo 'Falta la configuración cifrada. Ejecuta bash tool/prepare_environment.sh.' >&2
  exit 1
fi
if [[ -f .env.dart-defines.json ]]; then
  flutter run --dart-define-from-file=.env.dart-defines.json "$@"
else
  flutter run "$@"
fi
