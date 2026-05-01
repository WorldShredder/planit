<div align=center>
    <img src='/../assets/logo.png' />
</div>
<h1 align=center>Documentation</h1>
<h3 align=center>Configuration & Customization</h3>
<br>
<br>

**Planit** offers a number of configuration options to customize functionality, look and layout. Configurations can be applied at the installer level and module directory level.

## Config Files

### Global Config

**Planit** consumes a primary config of name `planit.conf` located in the same directory as the main `planit` directory. This config is sourced outside of the main event loop and before any modules are loaded.

If this config is located elsewhere, or if the config file name deviates from the expected `planit.conf`, you must assign its path to `PLAN__PATH_CONFIG` before calling `planit`, or pass it as a commandline argument to `planit` using the `-c|--config` option:

```sh
config_path="${HOME}/settings.config"
planit/planit --config "$config_path"
```

### Directory Config

Each module directory, including the root module directory, may contain a `module.conf` or `planit.conf` configuration to apply directory-level options. Module directories can leverage all options except **Planit** bootstrap options, such as `PLAN__PATH_MODULES`, `PLAN__PATH_CONFIG`, `PLAN__STATE_TRACK`, and so on.

This is useful when a group of modules rely on a specific execution command, a shared title, or when stylistic changes to the status log on a per-directory basis is desired.

A few additional options are provided for directory-level configs:

| Option | Default | Description
| ------ | ------- | -----------
| `PLAN__MODULE_TITLE` | | A title applied to each module under the directory and is best used with `PLAN__STATLOG_SHOW_INDEX` to delineate between modules.
| `PLAN__MODULE_CMD` | | A command used to execute each module in the directory, e.g., `bash`, `python3`, `source`, or any bash-compatible command or sequence. This value prefixes the module path. For more complex command strings, see [Module Commands](/docs/module-commands.md).
| `PLAN__MODULE_IGNORE_CODES` | | A comma-separated list of exit codes to ignore when module execution finishes. This sort of error handling is best handled in your modules.

## Settings

> [!NOTE]
> All color options _must_ use a valid [ANSI color code](https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit); values in range `0` to `255`. You can reset color formatting by using an out of range value, e.g., `256` or greater.

### General

| Option | Default | Description
| ------ | ------- | -----------
| `PLAN__PATH_CONFIG` | | Path to your main **Planit** config. This config is sourced outside of the main event loop and must be defined before calling `planit`. This can also be set via the `-c\|--config` commandline option.
| `PLAN__PATH_MODULES` | | Path to the directory containing your installer modules. Can also be set via the `-m\|--modules` commandline option and may be defined in your main **Planit** config.
| `PLAN__TERM_TIMEOUT` | 10 | Timeout (in seconds) before the installer is force killed. This is preceded by an attempt to terminate processes gracefully.

### Modules

| Option | Default | Description
| ------ | ------- | -----------
| `PLAN__MODULES_DEFAULT_TITLE` | `Running Module` | Module title used as a fallback if the current module title is improperly formatted.
| `PLAN__MODULES_ENFORCE_TITLE` | `false` | If `true`, do not use fallback title and return error if module title is incorrectly formatted.
| `PLAN__MODULES_DEFAULT_CMD` | | Default command used to execute each module, e.g., `bash`, `python3`, `source`, or any bash-compatible command or sequence. This value prefixes the module path. For more complex command strings, see [Module Commands](/docs/module-commands.md).
| `PLAN__MODULES_LOG_DIR` | | The directory where module logs are stored. Three log files are created: `err.log`, `out.log` and `all.log`. Only `all.log` contains messages from all modules, while `err.log` and `out.log` contain messages from the current module only. These logs are used by **Planit** to report module status info in the status log. If no path is given, **Planit** will generate a new temp directory using `mktemp -d`.
| `PLAN__MODULES_LOG_KEEP` | `false` | If `true`, do not cleanup log files when **Planit** exits.
| `PLAN__MODULES_SYMLINKS` | `false` | If `true`, allow symlinked modules and module directories.

### Installer State

| Option | Default | Description
| ------ | ------- | -----------
| `PLAN__STATE_TRACK` | `true` | If `true`, keep track of installation state and allow **Planit** to restore from a failed run.
| `PLAN__STATE_ID` | | Can be any string, conventionally the name and version of your project -- e.g., `MyInstaller-1.0` -- and use it to salt the state-file hash if `PLAN__STATE_HASH_ID` is `true`, otherwise set the _name segment_ of a plaintext state file to this value -- e.g., `planit.MyInstaller-1.0.state`.
| `PLAN__STATE_HASH_ID` | `true` | If `true`, generate a deterministic hash and use it as the _name segment_ of a hashed state file. If `PLAN__STATE_ID` is set, use it as a salt when generating the hash.
| `PLAN__STATE_DIR` | | The directory to store the installer state file. This can be a path, variable or Bash command substitution that returns a valid directory path. If no path is given, **Planit** will look a valid path first in `$TEMPDIR` then `/tmp`.

### Status Log

| Option | Default | Description
| ------ | ------- | -----------
| `PLAN__STATLOG_GET_TAIL` | `true` | If `true`, show last log entry from module output in status line.
| `PLAN__STATLOG_TAB_LEN` | `1` | Indentation length applied to sub-module status lines based on their directory depth. Set to `0` for no indentation.
| `PLAN__STATLOG_SHOW_DIR` | `true` | If `true`, show module directory names. Formatting rules apply, see [Naming Convention](/docs/naming-convention.md).
| `PLAN__STATLOG_SHOW_INDEX` | `true` | If `true`, show module index in status log.
| `PLAN__STATLOG_STICKY_INDEX` | `true` | If `true`, module index will remain in the module's status line after processing. If `false`, index only appears during module execution.
| `PLAN__STATLOG_SPINNER` | `\ \ \| \| / / - -` | Space-separated list of spinner characters, where each character represents a frame of animation. By default, each frame is displayed for 0.1 seconds. You can increase display duration in multiples of 0.1 by adding two or more of the same character. See [Spinner Examples](/docs/examples/spinner.md).
| `PLAN__STATLOG_SPINNER_COLOR` | `5` | Spinner character color displayed in the current status line during module execution.
| `PLAN__STATLOG_TITLE_COLOR` | `98` | Step title (module title) color.
| `PLAN__STATLOG_TAIL_COLOR` | `3` | Color of last log entry from module, displayed in the current status line during module execution.
| `PLAN__STATLOG_FAIL_ICON` | `-` | The icon or symbol displayed when a module fails during execution. This value is truncated if its length exceeds 1.
| `PLAN__STATLOG_FAIL_COLOR` | `1` | Color of step icon in status log when module fails during execution.
| `PLAN__STATLOG_OK_ICON` | `+` | The icon or symbol displayed when a module finishes successfully. This value is truncated if its length exceeds 1.
| `PLAN__STATLOG_OK_COLOR` | `2` | Color of step icon in status log when module finishes successfully.
| `PLAN__STATLOG_DIR_ICON` | | The icon displayed in front of module directory names.
| `PLAN__STATLOG_DIR_COLOR` | `4` | Color of directory icon (if any) displayed in status log.
| `PLAN__STATLOG_DIR_TITLE_COLOR` | `4` | Color of directory name displayed in status log.
| `PLAN__STATLOG_INDEX_L_COLOR` | `5` | Left index value color displayed in module status line.
| `PLAN__STATLOG_INDEX_R_COLOR` | `5` | Right index value color displayed in module status line.
| `PLAN__STATLOG_INDEX_BRACKET_L` | `(` | Left bracket character for the step index, e.g., `(` in `(x/y)`. This value is truncated if its length exceeeds 1.
| `PLAN__STATLOG_INDEX_BRACKET_R` | `)` | Right bracket character for the step index, e.g., `)` in `(x/y)`. This value is truncated if its length exceeds 1.
| `PLAN__STATLOG_INDEX_BRACKET_COLOR` | `5` | Color of bracket surrounding step index values.
| `PLAN__STATLOG_INDEX_DIVIDER` | `/` | Divider between the current step (module) index and max index, e.g, `/` in `(x/y)`. This value is truncated if its length exceeds 1.
| `PLAN__STATLOG_INDEX_DIVIDER_COLOR` | `5` | Color of divider between step index values.


### Logging

| Option | Default | Description
| ------ | ------- | -----------
| `PLAN__LOGGING_ERROR_PREFIX` | `[ERROR]` | Prefix of ERROR log messages.
| `PLAN__LOGGING_ERROR_COLOR` | `1` | Color of ERROR log messages.
| `PLAN__LOGGING_WARN_PREFIX` | `[WARN ]` | Prefix of WARN log messages.
| `PLAN__LOGGING_WARN_COLOR` | `3` | Color of WARN log messages.
| `PLAN__LOGGING_INFO_PREFIX` | `[INFO ]` | Prefix of INFO log messages.
| `PLAN__LOGGING_INFO_COLOR` | `4` | Color of INFO log messages.
| `PLAN__LOGGING_DEBUG_PREFIX` | `[DEBUG]` | Prefix of DEBUG log messages.
| `PLAN__LOGGING_DEBUG_COLOR` | `256` | Color of DEBUG log messages.

### UI

| Option | Default | Description
| ------ | ------- | -----------
| `PLAN__UI_HR_CHAR` | `─` | Character used for drawing horizontal lines in the terminal.


