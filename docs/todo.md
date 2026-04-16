<h1 align=center>Planit</h1>
<h3 align=center>Todo List</h3>
<br>

- [x] Derive module titles from directory/file names.

- [x] Implement substep feature.

- [ ] Store installer state on disk for install recovery.

- [ ] Optional configuration and planning through _yaml_ like **Ansible**.

    This will likely need something other than `yq`, e.g., **Python**. Require as little software as possible to use **Planit**.

- [ ] Create test cases.

- [ ] Handle requests on stdin (maybe?)

    This feature would be outside the scope of **Planit** but would be nice to have. Maybe allow bringing background process into foreground on an alt screen.

- [ ] Detect and alert stalled module.

    If stdin is handled with control provided by a foreground process in an alt screen, detection could offer a resolution route via the same system.

- [ ] Implement general terminal logging functions.

    <details>
    <summary>Show details...</summary>

    ```sh
    # Might be some bugs but looks right

    LOG_LEVEL="${PLAN__LOGGING_LEVEL:-NONE}"
    CALLER_LEVEL="${PLAN__LOGGING_CALLER_LEVEL}"

    declare -A LOG_LEVELS
    LOG_LEVELS[NONE]=0
    LOG_LEVELS[ERROR]=1
    LOG_LEVELS[WARN]=2
    LOG_LEVELS[INFO]=3
    LOG_LEVELS[DEBUG]=4

    declare -A LOG_LEVEL_ICONS
    LOG_LEVEL_ICONS[ERROR]="$PLAN__ICONS_LOG_ERROR"
    LOG_LEVEL_ICONS[WARN]="$PLAN__ICONS_LOG_WARN"
    LOG_LEVEL_ICONS[INFO]="$PLAN__ICONS_LOG_INFO"
    LOG_LEVEL_ICONS[DEBUG]="$PLAN__ICONS_LOG_DEBUG"

    declare -A LOG_LEVEL_COLORS
    LOG_LEVEL_ICONS[ERROR]="$PLAN__COLORS_LOG_ERROR"
    LOG_LEVEL_ICONS[WARN]="$PLAN__COLORS_LOG_WARN"
    LOG_LEVEL_ICONS[INFO]="$PLAN__COLORS_LOG_INFO"
    LOG_LEVEL_ICONS[DEBUG]="$PLAN__COLORS_LOG_DEBUG"

    PLAN::logger() {
        # init
        local level icon color
        for level in "${!LOG_LEVELS[@]}"; do
            [ "${LOG_LEVELS[$level]}" -le 0 ] &&
                continue
            icon="${LOG_LEVEL_ICONS[$level]}"
            [ -z "$icon" ] \
                && icon="[$level]"
            color="${LOG_LEVEL_COLORS[$level]}"
            eval "PLAN::log.${level,,}() { "\
                "PLAN::logger '${level}' '${icon}' '${color}' \"\$*\"; "\
            "}"
        done
        # logger
        PLAN::logger()
        {
            local level icon color message
            read -r level icon color message <<< "$@"
            local message="$*"
            # log() is never called directly
            if ! [ "${LOG_LEVELS[$LOG_LEVEL]}" -ge "${LOG_LEVELS[$level]}" ] \
            || ! [ "${LOG_LEVELS[$LOG_LEVEL]}" -gt 0 ]; then
                return 0
            fi
            local caller
            if [ "${LOG_LEVELS[$CALLER_LEVEL]}" -ge "${LOG_LEVELS[$level]}" ] \
            && [ "${LOG_LEVELS[$LOG_LEVEL]}" -gt 0 ]; then
                local caller="${FUNCNAME[2]}: "
            fi
            printf '%b%s %s%s\033[0m\n' "$color" "$icon" "$caller" "$message"
        }
    }
    ```

    Usage:

    ```sh
    # Initialize logging functions
    PLAN::logger

    # Now we can use it
    PLAN::log.error Exiting with error code "$code"
    PLAN::log.warn Path does not exist "'$path'"
    PLAN::log.info Modules found in "'$path'"
    PLAN::log.debug Execution time "$((end-start))ms"
    ```

    </details>
