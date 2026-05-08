<div align=center>
    <img src='/../assets/logo.png' />
</div>
<h1 align=center>Documentation</h1>
<h3 align=center>Installer Modules</h3>
<br>
<div align=center>

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/WorldShredder/planit)

</div>
<br>

**Planit** manages installation via language-agnostic modules -- executable scripts or binaries that you write to handle the installation process. A module may also come in the form of a directory containing sub-modules or an `init` entrypoint.

## Modules Directory

**Planit** accepts a single directory in which all modules reside. When it comes to the directory location, you have two options:

1. #### Installer Scope

    A `modules` directory located on the same level as the `planit` directory. **Planit** searches for this directly by default and will automatically parse its contents.

    ```
    MyInstaller
    ├── install
    ├── modules/
    │   └── ...
    └── planit/
    ```

2. #### System Scope

    A directory located anywhere on the system, wherein its path is passed to **Planit** as a commandline argument, or assigned to `PLAN__PATH_MODULES` in your config.

    ```sh
    "${pwd}/planit/planit" --modules '/path/to/modules'
    ```

#### Why a directory instead of YAML?

While _yaml_ is certainly the more optimal route, and while yaml configuration is a planned feature, a parser is not readily available on every system. This breaks a core requirement of **Planit**: _to work anywhere Bash4 is installed, within reason._

## Module Types & Directory Structure

See: [Module Naming Convention](/docs/naming-convention.md)

A module can technically be written in any language; **Planit** will attempt to execute it as is unless `PLAN__MODULE_CMD` is set, or `PLAN__MODULES_DEFAULT_CMD` if the module's executable flag is not set.

#### Root Module

Executables that reside in the main `modules` directory are considered _root modules_ and offer the simplest route to building an installer.

```
modules/
├── 10_step_1.sh
├── 20_step_2.py
└── 30_step_3.js
```

#### Nested Module

A module may come in the form of a directory (naming conventions apply) containing one or more executable modules or sub-directory modules. This method benefits from better organization, clearer status log entries, and [group configs](#module-configuration).

```
modules/
├── 10_module_group_a/
│   ├── 10_step_a-1
│   ├── 20_step_a-2
│   └── 30_step_a-3
└── 20_module_group_b/
    ├── 10_step_b-1
    ├── 20_step_b-2
    └── 30_step_b-3
```

#### Directory Module

If **Planit** finds an `init` file (extension optional) in a directory, it treats the entire directory as a single module, where `init` becomes the sole executable and the directory name defines the install step title.

```
modules/
├── 10_download.sh
├── 20_install.sh
└── 30_configure/
    ├── init.py
    ├── src/
    │   └── ...
    └── scripts/
        └── ...
```

## Module Configuration

See: [Configuration & Customization](/docs/configuration.md)

**Planit** can be configured on a per-directory basis by creating a `planit.conf` or `module.conf` file in the target module directory or sub-directory. This config is sourced inside the module's subshell.

```
modules/ -------------------------------------.
├── 10_bootstrap/ -------------------------.  |---> #1 modules/module.conf
│   ├── 10_update_package_repositories.sh  |  |
│   ├── 20_install_dependencies.sh         |--|---> #2 bootstrap/module.conf
│   └── module.conf --------------subshell-'  |
├── 20_install/ ---------------------------.  |
│   ├── 10_[Downloading Neovim v2.1.1].sh  |  |
│   ├── 20_building_binary.sh              |--|---> #3 install/module.conf
│   ├── 30_installing_neovim.sh            |  |
│   └── module.conf --------------subshell-'  |
│   30_post_install/ ----------------------.  |
│   ├── 10_[Update PATH].sh                |--|---> #4 post_install/module.conf
│   ├── 20_cleaning_up.sh                  |  |
│   └── module.conf --------------subshell-'  |
├── 30_final_steps.sh                         |
└── module.conf ------------------------------'
```

## Module Environment

Each module is executed in a subshell, isolating it from **Planit's** primary event loop and other module environments. If `PLAN__MODULE_CMD` or `PLAN__MODULES_DEFAULT_CMD` is set to `source`, the module will have access to:

- **Planit** environment variables

- Installer configuration variables

- Module configuration variables

- Exported installer variables

> [!NOTE]
> This approach is not ideal for every scenario -- namely scenarios where one installation step would benefit from leveraging the environment of a previous step.

### Environment Variables

**Planit** exports some environment variables that can be accessed by your modules without requiring `source` as the module command.

| Variable | Description
| -------- | -----------
| `PLAN__PATH_ROOT` | The absolute path to the **Planit** directory where the `planit` binary is held.
| `PLAN__PATH_MODULE` | The absolute path to the current module binary.
| `PLAN__PATH_MODULE_DIR` | The absolute path to the current module's directory.

## Passing Commandline Args

Parsing commandline args and exporting the environment from your `install` wrapper will handle most use cases. However, if you require a more dynamic solution, you can rely on **Planit** passing its remaining commandline args to each module during execution.

The simplest way to accomplish this would be to pass `$@` when calling the main `planit` orchestrator:

```sh
# Separating planit args and module args with '--' is recommended
"${pwd}/planit/planit" [PLANIT_ARGS ...] -- [MODULE_ARGS ...]
```

Parsing can then be handled on a per-module basis or via a dedicated parser that is sourced/imported into each module. In the latter case, the `install` wrapper must export the parser's absolute path, or you can leverage `PLAN__PATH_ROOT` which points to the directory containing the `planit` binary.

For example, assume we have the following directory structure:

```
MyInstaller
├── modules/
├── planit/
├── parser.sh
└── install
```

We can then source `parser.sh` within our modules via:

```sh
source "${PLAN__PATH_ROOT}/../parser.sh"
```

