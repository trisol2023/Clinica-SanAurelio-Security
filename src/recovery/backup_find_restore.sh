#!/bin/bash
set -euo pipefail

# ---------------- CONFIGURACIÓN ----------------
TARGET_FILE="${1:-}"
DEST_PATH="${2:-}"
BACKUP_DIR="/backups/inmutables"
# -----------------------------------------------

if [[ -z "$TARGET_FILE" || -z "$DEST_PATH" ]]; then
    echo "Uso: $0 <archivo_a_buscar> <ruta_destino>"
    exit 1
fi

# Convertir ruta absoluta a relativa para búsqueda dentro del TAR
SEARCH_PATH="${TARGET_FILE#/}"

echo "Buscando $SEARCH_PATH en backups inmutables..."

# Buscar solo en los últimos 5 backups (eficiencia)
for f in $(ls -t "$BACKUP_DIR"/backup_*.tar.gz | head -n 5); do
    if tar -tf "$f" | grep -qF "$SEARCH_PATH"; then
        echo "Archivo encontrado en: $f"

        # -------- ZONA SEGURA (Sandbox de Restauración) --------
        TMP_DIR=$(mktemp -d)
        tar -xzf "$f" -C "$TMP_DIR" "$SEARCH_PATH"
        mv "$TMP_DIR/$SEARCH_PATH" "$DEST_PATH"
        rm -rf "$TMP_DIR"
        # -------------------------------------------------------

        echo "$f"
        exit 0
    fi
done

echo "Archivo no encontrado en backups."
exit 1
