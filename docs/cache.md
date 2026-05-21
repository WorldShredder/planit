<div align=center>
    <img src='/../assets/logo.png' />
</div>
<h1 align=center>Documentation</h1>
<h3 align=center>Cache Utilities</h3>
<br>
<div align=center>

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/WorldShredder/planit)

</div>
<br>

As of `v0.5.0-alpha`, **Planit** provides caching utilities to help manage ephemeral installer data and inter-process communication. Cached data will be stored in `$TEMPDIR` or `/tmp/`, unless `PLAN__PATH_CACHE` or `PLAN__PATH_VCACHE` are set. **Planit** will automatically cleanup cache directories by default.

For faster IPC, see [RAM Cache](#ram-cache) below.

## File Cache

A managed cache directory can be enabled by setting `PLAN__ENABLE_CACHE` to `true`. The file cache can then be used as a temporary data store for your modules and is accessible via the `PLAN__PATH_CACHE` environment variable. This points to `planit.{STATE_ID_HASH}.cache` in `TEMPDIR` by default unless otherwise specified in your config.

### Usage

```sh
# planit.conf
PLAN__ENABLE_CACHE='true'
```

```sh
# modules/10_download_rust.sh
curl --proto '=https' --tlsv1.2 -f https://sh.rustup.rs > "${PLAN__PATH_CACHE}/rustup"
```

```sh
# modules/20_install_rust.sh
sh "${PLAN__PATH_CACHE}/rustup" -y
```

## Variable Cache (VCache)

Variables can be stored in a scope-dependent cache, or _vcache_, for use in modules belonging to the same scope. **Planit** exposes [Plan::vcache](#functions) functions to your modules for _vcache_ management, and stores variables as files in `PLAN__PATH_VCACHE` under unique hashes to prevent cross-scope contamination. The path variable points to `planit.{STATE_ID_HASH}.vcache` in `TEMPDIR` unless otherwise specified in your config.

### Scope Overview

There are three scopes defining which modules have access to which _vcache_:

- #### Global Scope

    This cache is accessible from all modules, including those defined in `PLAN__PATH_MODULES`.

    **Cache Location**: `${PLAN__PATH_VCACHE}/global.d/`

- #### Root Scope

    This cache is accessible from the current root module directory and its children. For example: `a/`, `b/`, and `c/` in `modules/a/b/c/` all share the same _root_ scope. The root scope of the `modules` directory acts as a secondary local scope.

    **Cache Location**: `${PLAN__PATH_VCACHE}/root.d/`

- #### Local Scope

    This _vcache_ is accessible from the current module directory only. For example: all directories in `modules/a/b/c/` have their own _local_ scope, with `c/` being the active scope.

    **Cache Location**: `${PLAN__PATH_VCACHE}/local.d/`

How scopes look from a module perspective:

```
modules/ --------------------- Global Scope --.
├── 10_bootstrap/ -------------------------.  |--> Local Scope (A)
│   ├── 10_update_repositories.sh          |--|--> Root Scope (A)
│   ├── 20_install_dependencies.sh         |--|--> Local Scope (B)
│   └── module.conf -----------------------'  |
├── 20_install/ ---------------------------.  |
│   ├── 10_download_neovim.sh              |  |
│   ├── 20_build_binary.sh                 |--|--> Root Scope (B)
│   ├── 30_install_neovim.sh               |--|--> Local Scope (C)
│   ├── 40_post_install/ ---------------.  |  |
│   │   ├── 10_[Update PATH].sh         |--|--|--> Local Scope (D)
│   │   ├── 20_verify_install.sh        |  |  |
│   │   └── module.conf ----------------'  |  |
│   ├── 50_cleanup/ --------------------.  |  |
│   │   ├── 10_build_dependencies.sh    |--|--|--> Local Scope (E)
│   │   ├── 20_environment.sh           |  |  |
│   │   └── module.conf ----------------'  |  |
│   └── module.conf -----------------------'  |
└── module.conf ------------------------------'
```

### Functions

> [!NOTE]
> The `SCOPE` can be passed in uppercase, lowercase or prefix, e.g.: `GLOBAL`, `global` or `g`.

- #### `Plan::vcache.add [OPTION ...] SCOPE NAME VALUE`

    Define a variable `NAME` with value `VALUE` in scope `SCOPE`.

    ```
    Options:
      -e, --env  Export variable in current environment as well. This option
                 overrides the -s|--set option.
      -s, --set  Declare variable in current script's global scope but do
                 not export.
    ```

- #### `Plan::vcache.del [OPTION ...] SCOPE NAME`

    Undefine a variable `NAME` from scope `SCOPE` and the current environment.

    ```
    Options:
      -e, --env  Unset variable in current environment as well.
    ```

- #### `Plan::vcache.clear [OPTION ...] SCOPE`

    Clear a given _vcache_ by scope.
    
    ```
    Options:
      -e, --env  Unset all variables of SCOPE in current environment as well.
    ```

### Usage

```sh
# planit.conf
PLAN__ENABLE_VCACHE='true'
```

```sh
# modules/10_rust/10_download.sh
Plan::vcache.add -s local rust_path "$(mktemp)"
curl --proto '=https' --tlsv1.2 -f https://sh.rustup.rs > "$rust_path"
```

```sh
# modules/10_rust/20_install.sh
sh "$rust_path" -y
```

```sh
# modules/10_rust/30_cleanup.sh
rm -f "$rust_path"
Plan::vcache.clear local
```

## Persistent Cache

You can control whether or not data in the _file cache_ and _vcache_ persists across multiple installer sessions by setting `PLAN__KEEP_CACHE` and `PLAN__KEEP_VCACHE`.

### Options

- `never` (default): Never keep cached data.
- `onfail`: Keep cached data only when the installer fails.
- `always`: Always keep cached data.

## RAM Cache

Linux offers `/dev/shm` -- a world-writable directory acting as a form of _ramdisk_. If your installer is I/O intensive and uses **Planit** cache utilities, it may be worth considering moving cache storage to RAM, given that it is considerably faster than disk storage.

In most cases, however, this approach is completely unnecessary.

### Setup

> [!WARNING]
> `/dev/shm` support is optional within the kernel config and has limits set in `/etc/default/tmpfs`. As such, you must ensure the system executing the installer is compatible with the `shm` storage device.
>
> You should also consider setting `PLAN__KEEP_CACHE` or `PLAN__KEEP_VCACHE` to `never` or `onfail`, given how limited RAM is as a resource compared to disk storage.

Setting commandline option `--cache` or `--vcache` to `/dev/shm` is enough to configure ram cache. This should only be done after confirming the shared memory device exists.

```sh
# install
cd "$(dirname "${BASH_SOURCE[0]}")"

cache_dir=''
[ -e /dev/shm ] \
    && cache_dir='/dev/shm'

planit/planit \
    --cache "$cache_dir" \
    --vcache "$cache_dir"
```

Make sure to disable the above options in your config and enable caching:

```sh
# planit.conf
PLAN__ENABLE_CACHE='true'
PLAN__ENABLE_VCACHE='true'
# Or use 'onfail' here
PLAN__KEEP_CACHE='never'
PLAN__KEEP_VCACHE='never'
#PLAN__PATH_CACHE='path/to/cache'
#PLAN__PATH_VCACHE='path/to/vcache'
```
