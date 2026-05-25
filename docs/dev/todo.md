<div align=center>
    <img src='/../assets/logo.png' />
</div>
<h3 align=center>Todo List</h3>
<br>
<div align=center>

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/WorldShredder/planit)

</div>
<br>

### Module/Process Handling

- [x] Derive module titles from directory/file names.

- [x] Implement substep feature.

- [x] `utils.cleanup()` is probably killing PIDs in an unsafe manner for long running sessions.

    **Options:**

    1. Kill by job.
    2. Kill all children, e.g.: `kill -- -$$` with `SIGTERM` trap.
    3. Remove successful PIDs from `PLAN__PID_CACHE` (race conditions apply on cancel signal)

- [x] Allow passing arguments to module calls; maybe use a new module-specific config option (this would require the name of the specific module)

    This can be accomplished using `PLAN__MODULE_CMD` and `PLAN__MODULES_DEFAULT_CMD`. Command strings are parsed by `Plan::utils.parse_cmd()`.

- [x] Implement module index for non-default module titles.

    ```
    ✔ Updating Apt Repos (1/7)
    ✔ Installing Depends (2/7)
    ⣴ Cloning Branch 'main' (3/7)
    ```

- [ ] **(Critical)** Implement an `always_run` feature for directory modules.

    This solves the issue of failures occuring in `foo/module_n+1` where `foo/module_n` sets up the environment for its siblings via commandline args. In this scenario, `foo/module_n` is never recalled (state recovered on `foo/module_n+1`) thus changes to commandline args won't resolve issue.

    Solution: Implement some flag or file naming convention for modules that must always be executed when **Planit** enters a given directory, e.g.: `100_always@build_binary`

- [ ] **(Critical)** Add option to run custom cleanup scripts -- global scope and module scope -- before **Planit** cleanup.

- [ ] **(Critical)** Allow sourcing of modules in the main module execution loop.

    - [x] Allow general sourcing for access to **Planit** variables.

    - [ ] Module event loop must be ran in a subshell to prevent main environment contamination.

        - Currently modules can be sourced in their own isolated subshell.

    - [ ] Modules should be allowed to influence the environment of subsequent modules.

        - This can be accomplished by allowing some modules to be sourced into the main execution loop.

    - [ ] Require `.sh` sourcing only.

- [ ] **(Critical)** Expose more environment variables to modules for additional control over installer state, e.g., internal step recovery.

- [ ] **(Critical)** When `PATH__MODULE_TITLE` is set, module status lines should be merged into a single status line that reports sub-module indexes or percentage.

    ```
    - (1/2) Running Module Group 1 [6/6]
    - (2/2) Running module Group 2 [5/8]
    ```

    ```
    - (1/2) Running Module Group 1 [100%]
    - (2/2) Running Module Group 2 [75%]
    ```

- [ ] Handle requests on stdin (maybe?)

    This feature would be outside the scope of **Planit** but would be nice to have. Maybe allow bringing background process into foreground on an alt screen. Would reduce compatibility unless a very robut method was used.

- [ ] Detect and report stalled module with a provided timout.

    If stdin is handled with control provided by a foreground process in an alt screen, detection could offer a resolution route via the same system.

- [ ] Expand `.planitignore` logic to function more like `.gitignore` within the module directory scope. The existence of an empty `.planitignore` should cause planit to ignore the entire directory (current function).

### State & Recovery

- [x] Store installer state on disk for install recovery.

    - [x] State file should contain hash of module's relative path for cleaner storage and to allow moving installer directory without losing state.

- [x] Recovery mode should print success status for each completed module.

- [ ] Implement internal step recovery; this can be accomplished by exposing modules to an environment variable pointing to its own FIFO and a function to calculate an internal state hash.

### Cache

- [x] Root and local vcaches should use not use unified directories ~unless configured as such with `PLAN__UNIFY_VCACHE`~. Instead, each cache layer should be its own directory to allow restoring previous cache states when traversing back up the local and root layers.

    This adds better nesting compatibility to vcache.

    #### Example
    ```sh
    modules/a     # local layer = a (new)
    modules/a/b   # local layer = b (new)
    modules/a/b/c # local layer = c (new)
    modules/a/b   # local layer = b (restored)
    modules/a     # local layer = a (restored)
    ```

- [x] VCache IDs should be deterministic hashes to help with above implementation.

    #### Example
    ```sh
    planit.*.vcache/
        global.d/
            global_var_a
            global_var_b
            global_var_c
        root.d/
            78ff0f7e5d9bb859/
                root_var_a
                root_var_b
            9434bd9319af9442/
                root_var_a
                root_var_b
        local.d/
            295ca74a2d1e5c70/
                local_var_a
            08d879bea85218ee/
                local_var_a
                local_var_b
    ```

- [ ] Add option to restrict external access to file cache and vcache.

    In most cases only the executing user and root should need access to cached data, but this should be optional in case modules feed cached data to external users or group users.

### Configuration

- [x] Add options to disable/enable directory display in the event log.

- [ ] Optional configuration and planning through _yaml_ like **Ansible**.

    This will likely need something other than `yq`, e.g., **Python**. Require as little software as possible to use **Planit**.

- [ ] Create proper config parser rather than sourcing configs as a shell script.

    ```sh
    Plan::config.parse() {
        local path="$1"
        ! [ -f "$path" ] \
            && return 1
        local line k v
        while IFS=$'\n' read -r line; do
            line="${line%${line##*[![:space:]]}*}"
            line="${line#*${line%%[![:space:]]*}}"
            [ "${line::1}" = '#' ] \
                && continue
            ! [[ "$line" =~ ^ *[a-zA-Z0-9_]+\ *=\ *.+$ ]] \
                return 1
            IFS='=' read -r k v <<< "$line"
            k="${k// /}"
            v="${v#*${v%%[![:space:]]*}}"
            if [[ "$v" =~ ^".+"$ ]]; then
                Plan::config.strip v \"
            elif [[ "$v" =~ ^'.+'$ ]]; then
                Plan::config.strip v \'
            fi
        done < "$path"
    }

    Plan::config.strip() {
        local -n nameref="$1"
        local char="$2"
        [ "${nameref::1}" = "$char" ] \
            && nameref="${nameref:1}"
        [ -z "${nameref##*"$char"}" ] \
            && nameref="${nameref%${char}*}"
    }
    ```

### Logging & Reporting

- [x] Implement general terminal logging functions.

- [x] **Planit**-specific error should not lead to printing `err.log`.

- [ ] We need proper debug logging for `import.sh`. This can be accomplished via several means:

    1. Create an `import.sh`-specific logger which could plug into the `PLAN__LOGER_*` environment variables; not the most appealing solution.
    
    2. #1 but using `import.sh`-specific environment variables; maybe ideal given import logs can make parsing debug messages annoying.

    3. Refactor `logging.sh` as a completely independant module; seems the most reasonable solution.

- [ ] Add more debug logs.

- [ ] Handle truncating on entire status message string in `report.status()`. Current method in `monitor.sh` doesn't account for long module titles.

- [ ] Consider switching out `tput` commands for a full `printf` solution: `printf '\r%-*s' "$delta" "status"`. This would go along with the line-trunction todo.

### User Interface

- [ ] Implement a `ui.sh` library for drawing padded boxes and containers.

    Use for displaying installer steps and errors.

- [ ] Add progress percent/bar functionality via new fifo `PLAN__PATH_FIFO_PROGRESS`.

### Testing

- [ ] Create test case for framework bootstrap.

- [ ] Create test cases for import system.

- [ ] Create test cases for `logging.sh`

- [ ] Create test cases for `modules.sh`

- [ ] Create test cases for `monitor.sh`

- [ ] Create test cases for `proc.sh`

- [ ] Create test cases for `utils.sh`

- [ ] Create test cases for installer:

    - [ ] w/no sub-directories

    - [ ] w/sub-directories

    - [ ] w/sub-directories & `init.sh`

### Documentation

- [ ] Transfer in-file docstrings to Markdown, leaving only `Usage` line comments.

- [ ] Create a `print_help` function or `src/planit/docs/help.txt` and add a `-h|--help` parameter to **Planit's** option parser.
