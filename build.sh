#!/usr/bin/env bash

# TODO: arg parsing
# TODO: create new notes subdir with command
# TODO: build only specified notes
# TODO: update eisvogel with command

set -Eeuxo pipefail

dir_root=$(dirname "$(readlink -f "$0")")
dir_notes=$dir_root/notes
dir_out=$dir_root/out

log() {
    echo >&2 "$1"
}

if ! command -v pandoc &>/dev/null; then
    log "pandoc not found!"
    exit 1
fi

rm -rf "$dir_out"
mkdir -p "$dir_out"

mkdir -p "$dir_notes"
cd "$dir_notes"

for this in *; do

    echo building "$this"

    if [ ! -f "$this"/metadata.yaml ]; then
        log "missing metadata.yaml in $this"
        continue
    fi

    if [ ! -f "$this"/notes.md ]; then
        log "missing notes.md in $this"
        continue
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
        "$this"/metadata.yaml \
        "$this"/notes.md \
        ../common/metadata.yaml \
        --output="$dir_out"/"$this".pdf

done
