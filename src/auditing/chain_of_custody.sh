#!/bin/bash
set -euo pipefail

LOGFILE="/var/log/cadena_custodia.log"

TYPE="${1:-UNKNOWN}"
IP="${2:-0.0.0.0}"
USER_NAME="${3:-SYSTEM}"
FILE="${4:-N/A}"
HASH="${5:-N/A}"
RESULT="${6:-INFO}"
SOURCE="${7:-N/A}"
DETAILS="${8:-None}"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

jq -n \
  --arg ts "$TIMESTAMP" \
  --arg type "$TYPE" \
  --arg ip "$IP" \
  --arg user "$USER_NAME" \
  --arg file "$FILE" \
  --arg hash "$HASH" \
  --arg result "$RESULT" \
  --arg source "$SOURCE" \
  --arg details "$DETAILS" \
  '{timestamp:$ts,type:$type,ip:$ip,user:$user,file:$file,hash:$hash,result:$result,source:$source,details:$details}' \
  >> "$LOGFILE"
