<div align=center>
    <img src='/../assets/logo.png' />
</div>
<h1 align=center>Documentation</h1>
<h3 align=center>Logging</h3>
<br>
<div align=center>

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/WorldShredder/planit)

</div>
<br>

## Framework Logging

Log messages produced by the **Planit** framework are handled by the [logging.sh](/src/planit/lib/logging.sh) library. Several levels and associated functions are provided by this library, and can be used by your `install` wrapper if needed.

These loggers occupy the `Plan::log.*` function namespace and `PLAN__LOGGING_*` variable namespace. Logger output is sent over `stderr` only (no writes to disk).

### Usage

To use a logger externally, such as in your `install` wrapper, you must source the base `planit.conf` and the `logging.sh` library. Optionally you can source your custom `planit.conf` after the base configuration to apply desired changes.

Example below assumes a `planit/` directory on the same level as your `install` wrapper:

```sh
# MyInstaller/install
pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${pwd}/planit/planit.conf"
source "${pwd}/planit.conf"

# Logging module relies on this variable
PLAN__PATH_ROOT="${pwd}/planit"

# Specifying the component for a minimal import
source "${pwd}/planit/lib/logging.sh" --component logger
```

### Functions

```
Plan::log.debug MESSAGE
```

- **Level**: `ERROR`
- **ID**: `1`

```
Plan::log.warn MESSAGE
```

- **Level**: `WARN`
- **ID**: `2`

```
Plan::log.info MESSAGE
```

- **Level**: `INFO`
- **ID**: `3`

```
Plan::log.error MESSAGE
```

- **Level**: `ERROR`
- **ID**: `4`

## Module Logging

Output from modules on `stdout` and `stderr` are captures by the `monitor.sh` library and redirected to two named pipes as a preprocessing step. These messages are then collected and written to the `out.log`, `err.log` and `all.log` log files, stored in `PLAN__MODULES_LOG_DIR`. These messages are then displayed in the status log next to the module title, depending on your configuration.

**Planit** also provides a special log file called `mod.log` which can only be written to using the `Plan::log.mod` function. This function is defined and exported in the `logging.sh` library, and can be used in your modules to provide clearer inline status log entries.

> [!NOTE]
> The **Planit** error handler pulls messages from `err.log` exlusively and is not affected by the use of `Plan::log.mod`.

### Usage

In order to use `Plan::log.mod` effectively, set the following options in your main `planit.conf`, or any `module.conf`:

```sh
PLAN__STATLOG_TAIL_FROM='STDMOD' # Only report from mod.log
PLAN__STATLOG_KEEP_TAIL='true'   # (Optional) For completion log entries
PLAN__STATLOG_GET_TAIL='true'    # (Optional) ensures tail is printed
```

Now any message sent via `Plan::log.mod` will appear in the status log next to the active module title:

```sh
# modules/10_foo

Plan::log.mod "Installing packages: ${required[*]}"
sudo apt update -y
sudo apt install -y "${required[@]}"
Plan::log.mod --color '2' "Operation complete!"
```

### Functions

```
Plan::log.mod [-c|--color COLOR] [-d|--delay SECONDS] MESSAGE
```

| Option | Default | Description
| ------ | ------- | -----------
| `-c\|--color` | | An ANSI color code used as the message foreground color. Overrides the default status line color.
| `-d\|--delay` | `0.1` | How long to sleep, in seconds, after printing the message. When `PLAN__STATLOG_KEEP_TAIL` is `true`, setting this value to less than `0.1` seconds may result in abnormal behavior due to monitor polling speed of `0.05` seconds.

