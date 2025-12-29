#!/bin/bash
set -euo pipefail

WATCH_DIR="/srv/samba/fichas_clinicas"
SHADOW_DIR="/backups/shadow_copy"

inotifywait -m -r -e close_write,moved_to --format '%w%f' "$WATCH_DIR" | while read -r FILE; do
  REL="${FILE#$WATCH_DIR/}"
  DEST="$SHADOW_DIR/$REL"

  mkdir -p "$(dirname "$DEST")"

  if [ -f "$DEST" ]; then
    mv "$DEST" "$DEST.$(date -u +%Y%m%dT%H%M%SZ)"
  fi

  cp -p -- "$FILE" "$DEST"
  logger -t ShadowCopy "Shadow actualizado: $REL"
done
root@fandaur-virtual-machine:/home/fandaur# cat /var/ossec/active-response/bin/custom-heal
#!/bin/bash

LOG_FILE="/var/ossec/logs/active-responses.log"
read -r INPUT_JSON

FILEPATH=$(echo "$INPUT_JSON" | jq -r '.parameters.alert.syscheck.path // empty')
USER_NAME=$(echo "$INPUT_JSON" | jq -r '.parameters.alert.syscheck.audit.user.name // "unknown"')

echo "$(date) - WAZUH TRIGGER - Path: $FILEPATH User: $USER_NAME" >> "$LOG_FILE"

# Validación estricta antes de ejecutar
if [[ -n "$FILEPATH" && "$FILEPATH" == /srv/samba/fichas_clinicas/* ]]; then
    /usr/local/bin/self_heal.sh "$FILEPATH" "$USER_NAME" "Wazuh_Internal"
else
    echo "$(date) - INVALID PATH IGNORED: $FILEPATH" >> "$LOG_FILE"
fi
