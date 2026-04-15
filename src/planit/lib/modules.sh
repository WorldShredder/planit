#!/usr/bin/env bash

# Populates a provided array nameref with modules to execute
# Usage: modules.fetch ARRAY_NAMEREF MODULES_PATH
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

# Formats title of given module or returns a default title
# Usage: modules.format_title MODULE_PATH
PLAN::modules.format_title() {
    local name="${1##*/}"
    local -a title
    if [[ "$name" =~ ^[0-9]+_\[.+\](\.sh)?$ ]]; then
        name="${name#*\[}"
        name="${name%]*}"
        read -ra title <<< "$name"
    elif [[ "$name" =~ ^[0-9]+_.+(\.sh)?$ ]]; then
        name="${name#*_}"
        name="${name%.sh*}"
        local sub l r
        while read -rd_ sub; do
            l="${sub::1}"
            r="${sub:1}"
            title+=("${l}${r}")
        done <<< "$name"
    fi
    printf '%s' "${title[*]}"
}
