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
shift

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

if ! command -v 'Plan::import' &> /dev/null; then
    # Usage: import [-o|--overwrite] [-n|--namespace NAME] [MODULE]
    #
    # Checks the current environment for a given function under __NAMESPACE__
    # and returns non-zero exit code if function exists, unless -o|--overwrite
    # is set or __OVERWRITE__ is 'true'.
    #
    # If an array __C__ exists and is non-empty, import() will return `0` if
    # MODULE can be found in the array, otherwise return `1`.
    #
    # Positional Args:
    #   MODULE  The module to check for under __NAMESPACE__.
    #
    # Args:
    #   -o, --overwrite       Return 0 even if MODULE exists in environment. If
    #                         not set, value of __OVERWRITE__ is used.
    #   -n, --namespace NAME  The namespace to check under, otherwise namespace
    #                         is value of __NAMESPACE__.
    #
    Plan::import() {
        local namespace="$__NAMESPACE__"
        local overwrite="$__OVERWRITE__"

        while :; do
            case "$1" in
                -n | --namespace)
                    namespace="$2"
                    shift
                    ;;
                -o | --overwrite)
                    overwrite='true'
                    ;;
                --)
                    shift
                    break
                    ;;
                *) break ;;
            esac
            shift
        done

        local module="$1"
        local call_path="$namespace"
        [ -n "$module" ] \
            && call_path+=".${module}"

        if command -v "$call_path" &> /dev/null; then
            [ "$overwrite" != 'true' ] && return 1
        fi

        if [ -z "${__C__[*]}" ] || [ " ${__C__[*]} " == " $module " ]; then
            return 0
        fi

        return 1
    }

    Plan::import.clean() {
        # Usage: import.clean
        #
        # Cleanup environment variables defined by import.sh
        #
        unset __C__ __NAMESPACE__ __OVERWRITE__
    }
fi
