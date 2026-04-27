<div align=center>
    <img src='/../assets/logo.png' />
</div>
<h1 align=center>Documentation</h1>
<h3 align=center>Module Naming Conventions</h3>
<br>
<br>

Module names define two important properties:

1. The order-of-execution relative to each module's directory scope.

2. The installation step titles displayed in the status log, unless `PLAN__MODULE_TITLE` is already set.

## Name Format

**Planit** expects module file names to begin with an integer followed by an underscore; everything after this prefix is interpreted as a format string (see below). This ensures each module is executed in lexical order and provides **Planet** a clear delimiter to extract title format strings.

**Format:** `<PREFIX><TITLE>[.EXTENSION]`

> [!IMPORTANT]
> If the integer prefix is missing, **Planit** will use `PLAN__MODULES_DEFAULT_TITLE` as a fallback for the step title.

### Auto Format

Title segments written in _snake case_ are automatically formatted by **Planit** using _title case_. Underscores are interpreted as spaces and are required.

> [!IMPORTANT]
> If the name contains a `.`, then the file must include an extension, otherwise use [Raw Format](#raw-format). This is due to **Planet** trimming off the right-most `.`.

#### Example

- `10_updating_apt_repos` => `Updating Apt Repos`
- `20_install_foo_2.1.sh` => `Install Foo 2.1`

### Raw Format

Wrapping the title segment with `[]` will cause **Planit** to treat the title as a literal, with a few of caveats:

1. Spaces are allowed (although maybe discouraged)
2. Underscores are interpreted as spaces, but are not required.
3. The `%` symbol is used as an escape character for underscores.
4. To print a literal `%` you must escape it, i.e., `%%`.

#### Example

- `10_[Configure_RPC_Subsystem]` => `Configure RPC Subsystem`
- `20_[Installing Neovim 2.1.7]` => `Installing Neovim 2.1.7`
- `30_[95%%____Run_Foo%_Bar.py]` => `95%    Run Foo_Bar.py`


