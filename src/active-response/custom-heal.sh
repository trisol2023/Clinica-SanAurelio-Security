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
