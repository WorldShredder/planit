<div align=center>
    <img src='/../assets/logo.png' />
</div>
<h1 align=center>Documentation</h1>
<h3 align=center>Module Commands</h3>
<br>
<br>

The `PLAN__MODULE_CMD` and `PLAN__MODULES_DEFAULT_CMD` consumes a command that is used to execute a module or group of modules under a given module directory. The command must be a single keyword (e.g., `source`, `python3`, `bash`) optionally followed by commandline arguments, including strings.

> [!NOTE]
> Environment variables can be passed using `env` or `eval`.

#### Works

- `PLAN__MODULE_CMD='bash --noprofile --norc'`
- `PLAN__MODULE_CMD='env foo="bar" bash -xv'`
- `PLAN__MODULE_CMD='sudo -u "shred" bash'`

#### Doesn't Work

- `PLAN__MODULE_CMD='foo="bar" bash'`
- `PLAN__MODULE_CMD='foo="bar"; bash'`
