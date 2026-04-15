# Planit Spec

> [!NOTE]
> - Planit should be sourced with arguments:
>     - `-r|--root`: Tell Planit where it can find its library.
>     - `-m|--modules`: Defines directory containing modules to install.
>
> Example:
> ```sh
> # main.sh
> project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
> source "${project_root}/src/planit/planit" \
>   -r "${project_root}/src/planit" \
>   -m "${project_root}/modules"
> ```
>
> Alternatively:
> ```sh
> # main.sh
> project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
> PLAN__PATH_LIB="${project_root}/src/planit"
> PLAN__PATH_MODULES="${project_root}/modules"
> source "${PLAN__PATH_LIB}/planit"
> ```

1. Create handlers
    1. `Plan::handle.cleanup()`
        - Accepts two array name references: `-p` for pid cache, `-f` for file cache.
        - Ensures all cached processes are killed.
        - Ensures all cached files and directories are removed.
    2. `Plan::handle.exit()`
        - Ensures trap flags are reverted.
        - Ensures normal cursor.
        - Ensures alt screens are destroyed (if necessary).
        - Ensures exit code propagation.
        - Runs cleanup handler with non-exit handler options.
        - Exits with propagated exit code.
2. Create utils
    1. `Plan::utils.ok()`
        - Accepts comma separated list of error codes to ingore: `-i CODE,...`
            ```sh
            IFS=, read -ra ignore <<< "$codes"; shift
            ```
        - Accepts space separated exit codes `CODE ...` after options.
        - Returns `0` if exit code is zero or ignored, otherwise returns `CODE`
3. Define misc
    1. `PLAN__SPINNER`
    2. `PLAN__COLOR_(NAME)`
3. Create pid and file cache arrays: `PLAN__PID_CACHE`, `PLAN__FILE_CACHE`
4. Define logging directory `mktemp -d`
    - `PLAN__PATH_LOG`
    - `PLAN__PATH_LOG_OUT`
    - `PLAN__PATH_LOG_ERR`
    - `PLAN__PATH_LOG_ALL`
5. Define fifo directory in `PLAN__PATH_LOG`
    - `PLAN__PATH_FIFO`
    - `PLAN__PATH_FIFO_OUT`
    - `PLAN__PATH_FIFO_ERR`
    - Add `PLAN__PATH_FIFO` to file cache
6. Create pipes `PLAN__PATH_FIFO_OUT` and `PLAN__PATH_FIFO_ERR`
7. Create `tee` listeners for `PLAN__PATH_FIFO_OUT` and `PLAN__PATH_FIFO_ERR`
    - Listeners should append `PLAN__PATH_LOG_ALL`
    - Listeners should replace `PLAN__PATH_LOG_(OUT|ERR)`
    - Listener pids should be cached in `PLAN__PID_CACHE`
8. Set trap `EXIT INT TERM HUP QUIT` for `Plan::handle.exit()`
    - Pass `-p PLAN__PID_CACHE` and `-f PLAN__FILE_CACHE`
