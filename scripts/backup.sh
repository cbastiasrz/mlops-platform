#!/usr/bin/env bash
set -euo pipefail

export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

REPO_DIR="$HOME/mlops-platform"
DATA_DIR="/srv/ml"

# carga RESTIC_REPOSITORY, RESTIC_PASSWORD y las variables de rclone,
# desencriptadas solo en memoria de este proceso
set -a
source <(sops -d "$REPO_DIR/restic.enc.env")
set +a

# vuelca Postgres solo si el contenedor ya existe (llega en el capítulo 8)
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^platform-postgres-1$'; then
  docker exec platform-postgres-1 pg_dumpall -U postgres > "$DATA_DIR/backups/postgres_$(date +%F).sql"
  echo "[ml-backup] postgres dump ok"
else
  echo "[ml-backup] postgres aun no existe, se omite el dump por ahora"
fi

# el respaldo real: los datos + el repo de la plataforma (incluye los .enc.env)
if restic backup "$DATA_DIR" "$REPO_DIR" --tag nightly; then
  echo "[ml-backup] ok $(date -Iseconds)"
else
  echo "[ml-backup] FALLO $(date -Iseconds)" >&2
  curl -s -d "Backup fallo en $(hostname) a las $(date -Iseconds)" "ntfy.sh/$NTFY_TOPIC" >/dev/null || true
  exit 1
fi
