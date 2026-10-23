#!/usr/bin/env bash
set -euo pipefail
# Same default key used by the app; ENV_ENCRYPTION_KEY can override it.
# Never source .env or print credentials.
dart run tool/encrypt_environment.dart
