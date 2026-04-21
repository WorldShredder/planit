#!/usr/bin/env bash

# shellcheck disable=SC1090,SC1091,SC2034

source "${PLAN__PATH_ROOT}/lib/utils.sh" --component depth2indent

# Initialize module
source "${PLAN__PATH_ROOT}/import.sh" Plan::report "$@"

if Plan::import 'ok'; then
    # Usage: report.ok TITLE [DEPTH]
    #
    # Prints the success status message to the event log.
    #
    # Positional Args:
    #   TITLE  The title of the success message, e.g., module title.
    #   DEPTH  The indentation multiplier for utils.depth2indent()
    #
    Plan::report.ok() {
        local title="$1"
        local -i depth="${2:-0}"
        Plan::utils.depth2indent \
            "$depth" "$PLAN__STATLOG_TAB_LEN"
        printf '%b%s %b%s\033[0m\n' \
            "$PLAN__COLOR_STEP_OK" "$PLAN__ICON_STEP_OK" \
            "$PLAN__COLOR_STEP_TITLE" "$title"
    }
fi

if Plan::import 'fail'; then
    # Usage: report.fail TITLE [DEPTH]
    #
    # Prints the failure status message to the event log.
    #
    # Positional Args:
    #   TITLE  The title of the success message, e.g., module title.
    #   DEPTH  The indentation multiplier for utils.depth2indent()
    #
    Plan::report.fail() {
        local title="$1"
        local -i depth="${2:-0}"
        Plan::utils.depth2indent \
            "$depth" "$PLAN__STATLOG_TAB_LEN"
        printf '%b%s %b%s\033[0m\n' \
            "$PLAN__COLOR_STEP_FAIL" "$PLAN__ICON_STEP_FAIL" \
            "$PLAN__COLOR_STEP_TITLE" "$title"
    }
fi

if Plan::import 'status'; then
    # Usage: report.status SPIN_CHAR TITLE [LAST] [DEPTH]
    #
    # Prints the given status line of a (presumably) running module.
    #
    # Positional Args:
    #   SPIN_CHAR  The current spinner character and spinner padding size in
    #              format 'CHAR:SIZE', e.g.: '⣴:3' => '⣴  '. This character is
    #              printed as the message prefix.
    #   TITLE      The title of the success message, e.g., module title.
    #   LAST       The last line of a module's log for realtime reporting or
    #              any message to print right of TITLE.
    #   DEPTH      The indentation multiplier for utils.depth2indent()
    #
    Plan::report.status() {
        local spin_char="${1%:*}"
        local -i spin_len="${1##*:}"
        local title="$2"
        local last="$3"
        local -i depth="${4:-0}"
        Plan::utils.depth2indent \
            "$depth" "$PLAN__STATLOG_TAB_LEN"
        printf "%b%-${spin_len}s %b%s %b%s" \
            "$PLAN__COLOR_SPINNER" "$spin_char" \
            "$PLAN__COLOR_STEP_TITLE" "$title" \
            "$PLAN__COLOR_STEP_LAST" "$last"
    }
fi

if Plan::import 'dir'; then
    # Usage: report.dir TITLE [DEPTH]
    #
    # Prints a given title with directory styling.
    #
    # Positional Args:
    #   TITLE  The name of the directory/sub-module, e.g., module title.
    #   DEPTH  The indentation multiplier for utils.depth2indent()
    #
    Plan::report.dir() {
        local title="$1"
        local -i depth="${2:-0}"
        Plan::utils.depth2indent \
            "$depth" "$PLAN__STATLOG_TAB_LEN"
        local icon=''
        [ -n "$PLAN__ICON_DIR" ] \
            && local icon="$PLAN__ICON_DIR "
        printf '%b%s%b%s\033[0m\n' \
            "$PLAN__COLOR_DIR" "$icon" \
            "$PLAN__COLOR_DIR_TITLE" "$title"
    }
fi

Plan::import.clean
