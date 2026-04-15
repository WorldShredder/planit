#!/usr/bin/env bash

PLAN::modules.fetch() {
    local -n dest="$1"
    local src="$2"
    local path
    if [ -f "${path}/init.sh" ]; then
        dest+=("${path}/init.sh")
        return
    fi
    for path in "$src"/*; do
        if [ -L "$path" ] && [ "$PLAN__MODULES_SYMLINKS" != 'true' ]; then
            printf '\033[33m[%-5s] %s\033[0m\n' \
                'WARN' "Symlinks not allowed '$path'"
        fi
        if [ -d "$path" ]; then
            PLAN::modules.fetch "$1" "$path"
        elif [[ "$path" == *.sh ]]; then
            dest+=("$path")
        fi
    done
}

PLAN::modules.format_title() {
    :
}
