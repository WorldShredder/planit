#!/usr/bin/env bash

# shellcheck disable=SC1090,SC1091,SC2034

# Populates a provided array nameref with modules to execute
# Usage: modules.fetch ARRAY_NAMEREF MODULES_PATH
# Return: Error on disallowed symlink
Plan::modules.fetch() {
    local -n dest="$1"
    local src="$2"
    local path
    if [ -f "${path}/init.sh" ]; then
        dest+=("${path}/init.sh")
        return
    fi
    for path in "$src"/*; do
        if [ -L "$path" ] && [ "$PLAN__MODULES_SYMLINKS" != 'true' ]; then
            printf '\033[31m[%-5s] %s\033[0m\n' \
                'ERROR' "Symlinks not allowed '$path'"
            return 1
        fi
        if [ -d "$path" ]; then
            Plan::modules.fetch "$1" "$path"
        elif [[ "$path" == *.sh ]]; then
            dest+=("$path")
        fi
    done
    return 0
}

# Formats title of given module or returns a default title
# Usage: modules.format_title MODULE_PATH
# Return: Formatted module title or empty
Plan::modules.format_title() {
    local name="${1##*/}"
    if [ "$name" == 'init.sh' ]; then
        # In this case we want to get the directory name
        name="${1%/*}"
        name="${name##*/}"
    fi
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
            title+=("${l^^}${r,,}")
        done <<< "${name}_"
    fi
    printf '%s' "${title[*]}"
}

# Get module config in given path
# Usage: modules.get_config MODULE_PATH|MODULE_DIR_PATH
# Return: Error on disallowed symlink or config path
Plan::modules.get_config() {
    local path="$1"
    local config
    if [ -e "$path" ]; then
        [ -f "$path" ] \
            && path="${path%/*}"
        if [ -f "${path}/planit.conf" ]; then
            config="${path}/planit.conf"
        elif [ -f "${path}/module.conf" ]; then
            config="${path}/module.conf"
        fi
    fi
    if [ -L "$config" ] && [ "$PLAN__MODULES_SYMLINKS" != 'true' ]; then
        printf '\033[31m[%-5s] %s\033[0m\n' \
            'ERROR' "Symlinks not allowed '$config'"
        return 1
    fi
    printf '%s' "$config"
}
