#!/usr/bin/env bash

# Usage: source /path/to/module [OPTION ...]
#
# Options
#   -c, --component  Specify one or more components to source; comma-separated.
#                    If no components are specified, all are imported.
#   -o, --overwrite  Overwrite existing components; disabled by default.
#
# Example
#   source my/module.sh -c fn1,fn2,fn3 --overwrite

# shellcheck disable=SC1090,SC1091,SC2034

declare -a __C__
__NAMESPACE__='Plan::utils'
__OVERWRITE__='false'

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

Plan::__import__() {
    # Handles source dynamically and prevents double imports
    local module="$1"
    local exists='false'
    command -v "${__NAMESPACE__}.${module}" &> /dev/null \
        && exists='true'

    if [ "$exists" == 'true' ] && [ "$__OVERWRITE__" != 'true' ]; then
        return 1
    fi

    if [ -z "${__C__[*]}" ] || [ " ${__C__[*]} " == " $module " ]; then
        return 0
    fi

    return 1
}

if Plan::__import__ 'ok'; then
    # Usage: utils.ok [-i|--ignore EXIT_CODE,...] EXIT_CODE [EXIT_CODE ...]
    Plan::utils.ok() {
        local -a ignore
        while :; do
            case "$1" in
                -i | --ignore)
                    IFS=, read -ra ignore <<< "$2"
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
        local code
        for code in "$@"; do
            if ((code > 0)) && [[ " ${ignore[*]} " != *" $code "* ]]; then
                return "$code"
            fi
        done
        return 0
    }
fi

if Plan::__import__ 'cleanup'; then
    # Usage: utils.cleanup [-p|--pids ARRAY_REF] [-f|--files ARRAY_REF]
    Plan::utils.cleanup() {
        local pids files
        while :; do
            case "$1" in
                -p | --pids)
                    local -n pids="$2"
                    shift
                    ;;
                -f | --files)
                    local -n files="$2"
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
        local target
        for target in "${pids[@]}"; do kill -9 "$target" 2> /dev/null; done
        for target in "${files[@]}"; do rm -rf "$target"; done
    }
fi

if Plan::__import__ 'exit'; then
    # Usage: utils.exit [CODE] [CLEANUP_OPTIONS...]
    Plan::utils.exit() {
        trap - INT TERM HUP QUIT EXIT
        tput cnorm
        local code=0
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            code="$1"
            if [ "$1" != '0' ]; then
                Plan::utils.print_error
                local show_log_dir_path
                [ -d "$PLAN__PATH_LOG" ] && [ "$PLAN__LOGGING_KEEP_LOGS" == 'true' ] \
                    && show_log_dir_path=" (see: '$PLAN__PATH_LOG')"
                printf '\033[31m[%-5s] %s%s\033[0m\n' \
                    'ERROR' "Planit failed with exit code '$code'" \
                    "$show_log_dir_path"
            fi
            shift
        fi
        Plan::utils.cleanup "$@" || true
        exit "$code"
    }

    # Usage: utils.print_error [MESSAGE]
    Plan::utils.print_error() {
        local message="${1:-$(cat "$PLAN__PATH_LOG_ERR" 2> /dev/null)}"
        if [ -n "$message" ]; then
            Plan::utils.hr '1:52' " $PLAN__PATH_LOG_ERR " >&2
            printf '%b%s\033[0m\n' "$PLAN__COLOR_STEP_FAIL" "$message" >&2
            Plan::utils.hr '1:52' >&2
        fi
    }
fi

if Plan::__import__ 'hr'; then
    # Print horizontal row with optional ansi escape colors and header
    # Usage: utils.hr [COLOR_FG:COLOR_BG] [HEADER]
    Plan::utils.hr() {
        local bg="${1%:*}"
        local fg="${1#*:}"
        local header="$2"
        local color_end='\033[0m'

        local -i cols i
        cols="$(tput cols)"
        (("${#header}" > cols)) \
            && header="${header::cols-1}-"
        local -i header_len="${#header}"
        local -i hr_len=cols-header_len
        local -i hr_llen=hr_len/2
        local -i hr_rlen=hr_len-hr_llen

        local hr="\033[0;38;5;${bg:-15}m"
        for ((i = 0; i < hr_llen; i++)); do hr+="$PLAN__ICON_HR"; done
        if [ -n "$header" ]; then
            hr+="\033[38;5;${fg:-0};48;5;${bg:-15}m$header"
            hr+="\033[0;38;5;${bg:-15}m"
        fi
        for ((i = 0; i < hr_rlen; i++)); do hr+="$PLAN__ICON_HR"; done

        printf '%b%b\n' "$hr" "$color_end"
    }
fi

if Plan::__import__ 'md5'; then
    Plan::utils.md5() {
        [ -z "$1" ] && return 1
        local res
        res="$(md5sum <<< "$1")" && cut -d' ' -f1 <<< "$res"
    }
fi

if Plan::__import__ 'sha1'; then
    Plan::utils.sha160() {
        [ -z "$1" ] && return 1
        local res
        res="$(sha1sum <<< "$1")" && cut -d' ' -f1 <<< "$res"
    }
fi

if Plan::__import__ 'sha256'; then
    Plan::utils.sha256() {
        [ -z "$1" ] && return 1
        local res
        res="$(sha256sum <<< "$1")" && cut -d' ' -f1 <<< "$res"
    }
fi

unset __C__ __NAMESPACE__ __OVERWRITE__
unset -f Plan::__import__
