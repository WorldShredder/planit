#!/usr/bin/env bash

# shellcheck disable=SC1090,SC1091,SC2034

PLAN__COLOR_SPINNER="${PLAN__COLOR_SPINNER:-'\033[38;5;75m'}"
PLAN__COLOR_STEP_TITLE="${PLAN__COLOR_STEP_TITLE:-'\033[38;5;99m'}"

source "${PLAN__PATH_ROOT}/lib/report.sh" --component status

# Usage: monitor.start PID [ARGS ...]
#
# Run a process monitor for a given process ID.
#
# Positional Args:
#   PID   The ID of the process to monitor.
#   ARGS  Additional args passed to monitor.loop().
#
# Return:
#   Exit code of given process.
#
Plan::monitor.run() {
    local proc_pid="$1"
    Plan::monitor.loop "$@" &
    local loop_pid="$!"

    wait "$proc_pid"
    local proc_code="$?"
    wait "$loop_pid"

    return "$proc_code"
}

# Usage: monitor.loop PID LOG_PATH [OPTIONS ...]
#
# Monitor a given PID and loop over process log entries from LOG_PATH.
# This function consumes a single terminal line to print the latest log entry
# and truncates the entry if it exceeds `tput cols`.
#
# Positional Args:
#   PID       The process ID to monitor.
#   LOG_PATH  Log file path to retrieve process logs from.
#
# Options:
#   -t, --title TITLE
#             Module title to display after spinner.
#   -d, --depth DEPTH
#             Depth of current module. This is a multiplier for
#             PLAN__STATLOG_TAB_LEN.
#   -s, --spinner SPINNER
#             Space-separated string of spinner segments to iterate over while
#             the loop is active. Displayed in front of -t|--title.
#
# Return:
#   Exit code (1) on error.
#
Plan::monitor.loop() {
    local proc_pid="$1"
    local log_path="$2"
    shift 2

    [ -z "$proc_pid" ] &&
        return 1

    local title="${PLAN__MODULE_TITLE:-Running Process}"
    local -i depth=0
    local spinner_str="${PLAN__ICON_SPINNER:-⡏ ⠟ ⠻ ⢹ ⣸ ⣴ ⣦ ⣇}"

    while :; do
        case "$1" in
            -t|--title) title="$2"; shift;;
            -d|--depth) depth="$2"; shift;;
            -s|--spinner) spinner_str="$2"; shift;;
            --) shift; break;;
            *) break;;
        esac
        shift
    done

    local -a spinner
    IFS=' ' read -ra spinner <<< "$spinner_str"

    # We need max spinner char len for prefix padding
    local c
    local -i spin_len=0
    for c in "${spinner[@]}"; do
        (( ${#c} > spin_len )) && spin_len="${#c}"
    done

    # We need to get message prefix len for padding
    local -i pre_len
    local -i indent="$depth * $PLAN__STATLOG_TAB_LEN"
    pre_len="$indent + $spin_len + ${#title} + 2"

    local last _last
    while kill -0 "$proc_pid" 2>/dev/null; do
        tput cr el

        if [ "$PLAN__STATLOG_GET_LAST" != 'false' ]; then
            _last="$(tail -n1 "$log_path" 2>/dev/null || :)"
            [ -n "$_last" ] &&
                last="$_last"
        fi

        # TODO: truncate prefix if prefix exceeds term cols
        local -i delta
        delta="$(tput cols)"-"$pre_len"-"${#last}"
        (( delta < 0 )) &&
            last="${last::delta-3}..."

        local -i spin_idx="${spin_idx:-0}"
        local spin_char="${spinner[$spin_idx]}"

        # printf "%b%-${spin_len}s %b%s %b%s" \
        #     "$PLAN__COLOR_SPINNER"    "$spin_char" \
        #     "$PLAN__COLOR_STEP_TITLE" "$title" \
        #     "$PLAN__COLOR_STEP_LAST"  "$last"

        Plan::report.status \
            "${spin_char}:${spin_len}" \
            "$title" \
            "$last" \
            "$depth"

        spin_idx=(spin_idx+1)%"${#spinner[@]}"
        sleep 0.1
    done
    tput cr el
}

