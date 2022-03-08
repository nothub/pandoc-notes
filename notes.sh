#!/usr/bin/env bash

set -Eeuo pipefail

dir_root=$(dirname "$(readlink -f "$0")")
dir_notes=$dir_root/notes
dir_out=$dir_root/out

log() {
    echo >&2 "${1-}"
}

usage() {
    cat <<EOM
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-n name] [-b name]

Available options:
-h    Print this help and exit
-v    Enable verbose output
-n    Initialize new notes directory
-b    Build specified notes directory
EOM
    exit
}

init() {
    if [ -d "$dir_notes"/"$1" ]; then
        log "directory present: $(realpath "$1")"
        exit 1
    fi

    log "creating notes directory: $(realpath "$1")"
    mkdir -p "$dir_notes"/"$1"

    cat <<EOF >"$dir_notes"/"$1"/metadata.yaml
---
title: "To foo a bar"
date: "1 January 1970"
---
EOF

    cat <<EOF >"$dir_notes"/"$1"/00_notes.md
# Heading Level 1

Example Text

## Heading Level 2

Example figure

![Coffee](https://www.w3.org/Icons/Misc/coffee.gif)
EOF

    exit 0
}

build() {
    echo building "$(realpath "$1")"

    if [ ! -d "$1" ]; then
        log "not a directory: $(realpath "$1")"
        return
    fi

    if [ ! -f "$1"/metadata.yaml ]; then
        log "missing metadata.yaml in: $(realpath "$1")"
        return
    fi

    if [ -z "$(find "$1" -iname '*.md')" ]; then
        log "no markdown files in: $(realpath "$1")"
        return
    fi

    pandoc --standalone \
        --fail-if-warnings \
        --highlight-style tango \
        --number-sections \
        --table-of-contents \
        --toc-depth=2 \
        --from=markdown \
        --to=latex \
        --template=../common/eisvogel.tex \
        "$1"/metadata.yaml \
        "$1"/*.md \
        ../common/metadata.yaml \
        --output="$dir_out"/"$1".pdf
}

build_target=''

while getopts vn:b:h opt; do
    case $opt in
    v) set -x ;;
    n) init "$OPTARG" ;;
    b) build_target="$OPTARG" ;;
    h | *) usage ;;
    esac
done

rm -rf "$dir_out"
mkdir -p "$dir_out"

cd "$dir_notes"
if [ -z "$build_target" ]; then
    for dir in *; do
        build "$dir"
    done
else
    build "$build_target"
fi
