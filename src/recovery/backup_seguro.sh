#!/bin/bash
set -euo pipefail

LOCKFILE="/var/lock/backup_seguro.lock"
exec 200>"$LOCKFILE"
flock -n 200 || exit 0

FECHA=$(date +"%Y-%m-%d_%H%M")
ORIGEN="/srv/samba"
DESTINO="/backups/inmutables"
ARCHIVO="backup_$FECHA.tar.gz"
FULL="$DESTINO/$ARCHIVO"

tar -czf "$FULL" -C "$ORIGEN" fichas_clinicas

chattr +i "$FULL"

if rclone copy "$FULL" boveda_segura:; then
  /usr/local/bin/chain_of_custody.sh "CLOUD_BACKUP" "LOCAL" "root" "$ARCHIVO" "N/A" "SUCCESS" "GoogleDrive" "Backup cifrado exitoso"
else
  /usr/local/bin/chain_of_custody.sh "CLOUD_BACKUP" "LOCAL" "root" "$ARCHIVO" "N/A" "FAIL" "GoogleDrive" "Error en subida"
f
