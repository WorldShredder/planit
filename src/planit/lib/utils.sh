#!/usr/bin/env bash

__COMPONENTS__=

while :; do
    case "$1" in
        -c | --componant)
            IFS=, read -ra __COMPONENTS__ <<< "$2"
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

if [ -z "${__COMPONENTS__[*]}" ] || [ " ${__COMPONENTS__[*]} " == ' ok ' ]; then
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

if [ -z "${__COMPONENTS__[*]}" ] || [ " ${__COMPONENTS__[*]} " == ' cleanup ' ]; then
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

if [ -z "${__COMPONENTS__[*]}" ] || [ " ${__COMPONENTS__[*]} " == ' exit ' ]; then
    # Usage: utils.exit [CODE] [CLEANUP_OPTIONS...]
    Plan::utils.exit() {
        trap - INT TERM HUP QUIT EXIT
        tput cnorm
        local code=0
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            if [ "$1" != '0' ]; then
                local show_log_dir_path
                [ -d "$PLAN__PATH_LOG" ] && [ "$PLAN__LOGGING_KEEP_LOGS" == 'true' ] \
                    && show_log_dir_path=" (see: '$PLAN__PATH_LOG')"
                printf '\n\033[31m[%-5s] %s%s\033[0m\n' \
                    'ERROR' 'Planit exiting with non-zero status' \
                    "$show_log_dir_path"
            fi
            code="$1"
            shift
        fi
        Plan::utils.cleanup "$@" || true
        exit "$code"
    }
fi

if [ -z "${__COMPONENTS__[*]}" ] || [ " ${__COMPONENTS__[*]} " == ' hr ' ]; then
    # Usage: utils.hr [COLOR]
    Plan::utils.hr() {
        local color="$1"
        local color_end
        [ -n "$color" ] \
            && color_end='\033[0m'
        local cols hr i
        cols="$(tput cols)"
        for ((i = 0; i < cols; i++)); do
            hr+="$PLAN__ICON_HR"
        done
        printf '%b%s%b\n' "$color" "$hr" "$color_end"
    }
fi
