<h1 align=center>Planit 🪐</h1>
<h3 align=center>Todo List</h3>
<br>

### Module/Process Handling

- [x] Derive module titles from directory/file names.

- [x] Implement substep feature.

- [x] `utils.cleanup()` is probably killing PIDs in an unsafe manner for long running sessions.

    **Options:**

    1. Kill by job.
    2. Kill all children, e.g.: `kill -- -$$` with `SIGTERM` trap.
    3. Remove successful PIDs from `PLAN__PID_CACHE` (race conditions apply on cancel signal)

- [ ] Detect and report stalled module with a provided timout.

    If stdin is handled with control provided by a foreground process in an alt screen, detection could offer a resolution route via the same system.

- [ ] Implement module counter for non-default module titles.

    ```
    ✔ Updating Apt Repos (1/7)
    ✔ Installing Depends (2/7)
    ⣴ Cloning Branch 'main' (3/7)
    ```

- [ ] Expose more environment variables to modules for additional control over installer state, e.g., internal step recovery.

- [ ] Allow passing arguments to module calls; maybe use a new module-specific config option (this would require the name of the specific module)

### State & Recovery

- [x] Store installer state on disk for install recovery.

    - [x] State file should contain hash of module's relative path for cleaner storage and to allow moving installer directory without losing state.

- [ ] Recovery mode should print success status for each completed module.

- [ ] Implement internal step recovery; this can be accomplished by exposing modules to an environment variable pointing to its own FIFO and a function to calculate an internal state hash.

### Configuration

- [ ] Optional configuration and planning through _yaml_ like **Ansible**.

    This will likely need something other than `yq`, e.g., **Python**. Require as little software as possible to use **Planit**.

### Logging & Reporting

- [x] Implement general terminal logging functions.

- [x] **Planit**-specific error should not lead to printing `err.log`.

- [ ] Handle requests on stdin (maybe?)

    This feature would be outside the scope of **Planit** but would be nice to have. Maybe allow bringing background process into foreground on an alt screen.

- [ ] Add more debug logs.

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

