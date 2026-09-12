#!/usr/bin/env bash
set -euo pipefail
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

REPO_DIR="$HOME/mlops-platform"

set -a
source <(sops -d "$REPO_DIR/restic.enc.env")
set +a

if restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune; then
  echo "[ml-retention] ok $(date -Iseconds)"
else
  echo "[ml-retention] FALLO $(date -Iseconds)" >&2
  curl -s -d "Retention fallo en $(hostname) a las $(date -Iseconds)" "ntfy.sh/$NTFY_TOPIC" >/dev/null || true
  exit 1
fi
