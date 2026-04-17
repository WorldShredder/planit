#!/usr/bin/env bash

# shellcheck disable=SC1090,SC1091,SC2034

source "${PLAN__PATH_ROOT}/lib/utils.sh" --component md5
source "${PLAN__PATH_ROOT}/lib/logging.sh" --component logger

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
            Plan::log.error "Symlinks not allowed '$path'"
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
        Plan::log.error "Symlinks not allowed '$config'"
        return 1
    fi
    printf '%s' "$config"
}

# Generate state hash for state file or module
# Usage: modules.save_state MODULE_PATH
# Return: 1 on error or hash string
Plan::modules.generate_state_hash() {
    local salt="$1"
    local state_id="${PLAN__STATE_ID}${PLAN__MODULES[*]}"
    [ -n "$state_id" ] \
        && Plan::utils.md5 "${salt}${state_id}"
}

Plan::modules.generate_module_hash() {
    # Relative module path to prevent losing state when moving install dir
    local module="${1#*${PLAN__PATH_MODULES}/}"
    Plan::modules.generate_state_hash "$module"
}

# Hash given module and store in state file
# Usage: modules.save_state MODULE_PATH
# Return: 0|1 depending on save state
Plan::modules.save_state() {
    local module state
    module="$1"
    if ! state="$(Plan::modules.generate_module_hash "$1")"; then
        Plan::log.error "Failed to generate module hash '$module'"
        return 1
    fi
    if ! printf '%s' "$state" > "$PLAN__STATE_PATH"; then
        Plan::log.error "Write to state file failed '$PLAN__STATE_PATH'"
        return 1
    fi
    return 0
}

Plan::modules.fetch_state() {
    local state
    state="$(cat "$PLAN__STATE_PATH" 2> /dev/null)" \
        || return 1
    printf '%s' "$state"
}

Plan::modules.fetch_state_idx() {
    local i state module_hash
    local -i state_idx=0
    state="$(Plan::modules.fetch_state)" || return 1
    for ((i = 0; i < "${#PLAN__MODULES[@]}"; i++)); do
        module_hash="$(Plan::modules.generate_module_hash "${PLAN__MODULES[$i]}")" \
            || return 1
        if [ "$state" == "$module_hash" ]; then
            state_idx="$i"
            break
        fi
    done
    printf '%d' "$state_idx"
}
