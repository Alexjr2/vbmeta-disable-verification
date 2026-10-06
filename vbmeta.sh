#!/bin/bash

##################################################
# vbmeta Verification Disabler Script
##################################################
set -e

WDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

init_requirements() {
    echo "[INFO] Checking requirements..."

    if ! command -v python3 >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y python3
    fi

    if [ ! -f "$WDIR/patch-vbmeta.py" ]; then
        echo "[ERROR] patch-vbmeta.py file not found in $WDIR"
        exit 1
    fi

    if [ ! -f "$WDIR/vbmeta.img" ]; then
        echo "[ERROR] vbmeta.img not found in $WDIR"
        exit 1
    fi

    mkdir -p "$WDIR/recovery" "$WDIR/output"
}

process_vbmeta() {
    mv "$WDIR/vbmeta.img" "$WDIR/recovery/vbmeta.img"

    local target="$WDIR/recovery/vbmeta.img"

    echo "[INFO] Patching vbmeta.img..."
    python3 "$WDIR/patch-vbmeta.py" "$target"

    cp "$target" "$WDIR/output/vbmeta.img"
}

cleanup() {
    rm -f "$WDIR/recovery/vbmeta.img"
    echo "[INFO] Cleanup complete."
}

init_requirements
process_vbmeta
cleanup
