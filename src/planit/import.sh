#!/usr/bin/env bash

# Usage: source /path/to/module [OPTION ...]
#
# Options
#   -c, --component  Specify one or more components to source; comma-separated.
#                    If no components are specified, all are imported.
#   -o, --overwrite  Overwrite existing components; disabled by default.
#
# Initialization
#   source path/to/import.sh NAMESPACE
#
# Example
#   source my/module.sh -c fn1,fn2,fn3 --overwrite

__NAMESPACE__="$1"
__OVERWRITE__='false'

declare -a __C__

while :; do
    case "$1" in
        -c | --component)
            IFS=, read -ra __C__ <<< "$2"
            shift
            ;;
        -o | --overwrite)
            __OVERWRITE__='true'
            ;;
        --)
            shift
            break
            ;;
        *) break ;;
    esac
    shift
done

Plan::import() {
    # Handles source dynamically and prevents double imports
    local module="$1"
    local call_path="${__NAMESPACE__}"
    [ -n "$module" ] \
        && call_path+=".${module}"
    local exists='false'
    command -v "$call_path" &> /dev/null \
        && exists='true'

    if [ "$exists" == 'true' ] && [ "$__OVERWRITE__" != 'true' ]; then
        return 1
    fi

    if [ -z "${__C__[*]}" ] || [ " ${__C__[*]} " == " $module " ]; then
        return 0
    fi

    return 1
}

Plan::import.clean() {
    unset __C__ __NAMESPACE__ __OVERWRITE__
    unset -f Plan::import
}
