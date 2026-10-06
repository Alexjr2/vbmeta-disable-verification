#!/bin/bash

##################################################
# vbmeta Verification Disabler Scripts
# made by @ravindu644 & @GoRhanHee & LLM AI Model
##################################################

shopt -s expand_aliases
set -e

export WDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p "recovery" "output" "log"

: > "${WDIR}/log/vbmeta_log.txt"

init_requirements(){
    echo -e "[INFO] Checking requirements..."
    if ! command -v python3 &> /dev/null; then
        sudo apt update && sudo apt install -y python3
    fi
    
    if [ ! -f "${WDIR}/patch-vbmeta.py" ]; then
        echo -e "[ERROR] patch-vbmeta.py file not found in ${WDIR}"
        exit 1
    fi
}

process_vbmeta(){
    mv vbmeta.img "${WDIR}/recovery/"
    cd "${WDIR}/recovery/"
    
    local FILE=$(ls)
    [[ "$FILE" == *.zip ]] && unzip "$FILE" && rm "$FILE"
    [[ "$FILE" == *.lz4 ]] && lz4 -d "$FILE" "${FILE%.lz4}" && rm "$FILE"
    [[ "$FILE" == *.tar ]] && tar -xf "$FILE" && rm "$FILE"

    if [ -f "vbmeta.img" ]; then
        export TARGET_VBMETA="$(pwd)/vbmeta.img"
    else
        echo -e "[ERROR] vbmeta.img not found."
        exit 1
    fi
    
    echo -e "[INFO] Patching vbmeta.img..."
    python3 "${WDIR}/patch-vbmeta.py" "${TARGET_VBMETA}" >> "${WDIR}/log/vbmeta_log.txt" 2>&1
    
    cp "${TARGET_VBMETA}" "${WDIR}/output/vbmeta.img"
    cd "${WDIR}/"
}

cleanup(){
    rm -rf "${WDIR}/recovery/"*
    echo -e "[INFO] Cleanup complete."
}

init_requirements
process_vbmeta
cleanup
