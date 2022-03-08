#!/usr/bin/env bash

# TODO: arg parsing
# TODO: verbose flag
# TODO: create new notes subdir with command
# TODO: build only specified notes
# TODO: update eisvogel with command

set -Eeu
set -x
set -o pipefail

dir_root=$(dirname "$(readlink -f "$0")")
dir_notes=$dir_root/notes
dir_out=$dir_root/out

log() {
    echo >&2 "$1"
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

    if [ ! -f "$1"/notes.md ]; then
        log "missing notes.md in: $(realpath "$1")"
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
        "$1"/notes.md \
        ../common/metadata.yaml \
        --output="$dir_out"/"$1".pdf
}

if ! command -v pandoc &>/dev/null; then
    log "pandoc not found!"
    exit 1
fi

rm -rf "$dir_out"
mkdir -p "$dir_out"

mkdir -p "$dir_notes"
cd "$dir_notes"

for dir in *; do
    build "$dir"
done
