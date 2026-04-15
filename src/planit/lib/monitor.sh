#!/usr/bin/env bash

PLAN__COLOR_SPINNER="${PLAN__COLOR_SPINNER:-'\033[38;5;75m'}"
PLAN__COLOR_STEP_TITLE="${PLAN__COLOR_STEP_TITLE:-'\033[38;5;99m'}"

# Usage: monitor.start PID [ARGS...]
# @param pid int: Process ID to monitor
# @param @args any: Args for monitor_loop()
# @return proc_code int, loop_code int
Plan::monitor.run() {
    local proc_pid="$1"
    Plan::monitor.loop "$@" &
    local loop_pid="$!"

    wait "$proc_pid"
    local proc_code="$?"
    wait "$loop_pid"

    return "$proc_code"
}

# Usage: monitor.loop PID LOG_PATH [TITLE] [SPINNER]
# @param proc_pid int: Process ID to monitor
# @param log_path str: Path to log file used by pid
# @param title str: Step title to print
Plan::monitor.loop() {
    local proc_pid="$1"
    local log_path="$2"
    local title="${3:-${PLAN__MODULE_TITLE:-Running Process}}"

    [ -z "$proc_pid" ] &&
        return 1

    local -a spinner
    local spinner_str="${4:-⡏ ⡏ ⠟ ⠟ ⠻ ⠻ ⢹ ⢹ ⣸ ⣸ ⣴ ⣴ ⣦ ⣦ ⣇ ⣇}"
    IFS=' ' read -r -a spinner <<< "$spinner_str"

    # We need max spinner char len for prefix padding
    local c
    local -i spin_len=0
    for c in "${spinner[@]}"; do
        (( ${#c} > spin_len )) && spin_len="${#c}"
    done

    # We need to get message prefix len for padding
    local -i pre_len
    pre_len="$spin_len"+"${#title}"+2

    local last _last
    # last="$(tail -n1 "$log_path" 2>/dev/null || :)"
    while kill -0 "$proc_pid" 2>/dev/null; do
        tput cr el

        _last="$(tail -n1 "$log_path" 2>/dev/null || :)"
        [ -n "$_last" ] &&
            last="$_last"

        local -i delta
        delta="$(tput cols)"-"$pre_len"-"${#last}"
        (( delta < 0 )) &&
            last="${last::delta-3}..."

        local -i spin_idx="${spin_idx:-0}"
        local spin_char="${spinner[$spin_idx]}"

        printf "%b%-${spin_len}s %b%s %b%s" \
            "$PLAN__COLOR_SPINNER"    "$spin_char" \
            "$PLAN__COLOR_STEP_TITLE" "$title" \
            "$PLAN__COLOR_STEP_LAST"  "$last"

        spin_idx=(spin_idx+1)%"${#spinner[@]}"
        sleep 0.1
    done
    tput cr el
}

