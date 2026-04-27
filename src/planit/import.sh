#!/usr/bin/env bash

# Usage: source path/to/module [OPTION ...]
#
# Define new library modules with incremental import functionality. Provides
# two functions -- Plan::import() and Plan::import.clean() -- to manage your
# import environment.
#
# Positional Args:
#   NAMESPACE  The namespace assigned to the module and used in the name of
#              each module component, e.g., 'Plan::utils' in 'Plan::utils.md5'.
#
# Options
#   -c, --component  Specify one or more components to source; comma-separated.
#                    If no components are specified, all are imported.
#   -o, --overwrite  Overwrite existing components; disabled by default.
#
# Module Initialization
#   source path/to/import.sh NAMESPACE
#
# Module Components
#   if Plan::import 'MyFunction'; then
#       NameSpace.MyFunction() { echo 123; }
#   fi
#
# Importing Components
#   source my/module.sh --component MyFunction
#

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

if ! declare -F 'Plan::import' &> /dev/null; then
    # Usage: import [-o|--overwrite] [-n|--namespace NAME] [MODULE]
    #
    # Checks the current environment for a given function under __NAMESPACE__
    # and returns non-zero exit code if function exists, unless -o|--overwrite
    # is set or __OVERWRITE__ is 'true'.
    #
    # If an array __C__ exists and is non-empty, import() will return '0' if
    # MODULE can be found in the array, otherwise return '1'.
    #
    # Positional Args:
    #   MODULE  The module to check for under __NAMESPACE__. If MODULE starts
    #           with an '+', the module is considered a module group, where
    #           everything after the '+' is the group identifier. In this mode
    #           import() will declare a function with an fname of identifier
    #           under __NAMESPACE__ if it does not already exist.
    #
    # Args:
    #   -o, --overwrite
    #              Return 0 even if MODULE exists in environment. If not
    #              set, value of __OVERWRITE__ is used.
    #   -n, --namespace NAME
    #              The namespace to check under, otherwise namespace is value
    #              of __NAMESPACE__.
    #   -r, --required REQUIRED
    #              Comma-separated string of required inner-module functions.
    #              This is necessary for module functions that all rely on the
    #              same independent function within the module. Required
    #              components extend the __C__ array and must be defined after
    #              the component requiring them.
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
                -r | --require)
                    # only extend components array when not importing all
                    if [ "${#__C__[@]}" -gt 0 ]; then
                        local required req
                        IFS=, read -ra required <<< "$2"
                        for req in "${required[@]}"; do
                            __C__+=("$req")
                        done
                    fi
                    shift
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
        if [ "${module::1}" = '+' ]; then
            ! [[ "${module:1}" =~ ^[a-zA-Z0-9\._]+$ ]] \
                && return 1
            call_path+=".${module:1}"
        elif [ -n "$module" ]; then
            call_path+=".${module}"
        fi

        if declare -F "$call_path" &> /dev/null; then
            if [ "$overwrite" != 'true' ]; then
                ## DEBUG
                # printf '\033[31m[DEBUG] import: %-20s %-20s %-50s <= %s\033[0m\n' \
                #     'Skipping' "$module" "$call_path" "${FUNCNAME[*]}"
                return 1
            fi
        fi

        # array expansion is safe here since IFS should never be in module name
        if [ -z "${__C__[*]}" ] || [[ " ${__C__[*]} " == *" $module "* ]]; then
            [ "${module::1}" = '+' ] \
                && eval "function $call_path { :; }"
            ## DEBUG
            # printf '\033[32m[DEBUG] import: %-20s %-20s %-50s <= %s\033[0m\n' \
            #     'Importing' "$module" "$call_path" "${FUNCNAME[*]}"
            return 0
        fi

        ## DEBUG
        # printf '\033[33m[DEBUG] import: %-20s %-20s %-50s <= %s\033[0m\n' \
        #     'Ignoring' "$module" "$call_path" "${FUNCNAME[*]}"
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
