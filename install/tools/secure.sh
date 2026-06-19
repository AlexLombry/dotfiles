#!/usr/bin/env bash
set -euo pipefail

ITER=600000

encrypt() {
    local input="$1"
    local output

    if [[ -d "$input" ]]; then
        output="${2:-${input}.tar.gz.enc}"
        tar czf - "$input" | openssl enc -aes-256-cbc -pbkdf2 -iter "$ITER" -out "$output"
    else
        output="${2:-${input}.enc}"
        openssl enc -aes-256-cbc -pbkdf2 -iter "$ITER" -in "$input" -out "$output"
    fi

    echo "Encrypted -> $output"
}

decrypt() {
    local input="$1"
    local output="${2:-}"

    if [[ "$input" == *.tar.gz.enc || "$input" == *.tgz.enc ]]; then
        openssl enc -d -aes-256-cbc -pbkdf2 -iter "$ITER" -in "$input" | tar xzf -
        echo "Decrypted and extracted."
    else
        [[ -z "$output" ]] && output="${input%.enc}"
        openssl enc -d -aes-256-cbc -pbkdf2 -iter "$ITER" -in "$input" -out "$output"
        echo "Decrypted -> $output"
    fi
}

usage() {
    echo "Usage:"
    echo "  secure encrypt <file|folder> [output]"
    echo "  secure decrypt <file.enc> [output]"
}

# Run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    cmd="${1:-}"
    shift || true
    case "$cmd" in
        encrypt) encrypt "$@" ;;
        decrypt) decrypt "$@" ;;
        *)       usage ;;
    esac
fi
