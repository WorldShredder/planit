<div align=center>
    <img src='../assets/logo.png' />
</div>
<h3 align=center>Installer Modules</h3>
<br>

**Planit** manages installation through modules -- executable scripts or binaries that you write to handle the installation process. A module may also come in the form of a directory containing sub-modules or an `init.sh` entrypoint.

> [!IMPORTANT]
> Each module is executed in a sub-shell, isolating it from **Planit's** primary event loop and other module environments. This is not always ideal, especially when one installation step leverages the environment of a previous step.
>
> Future versions of **Planit** will expose the installer to an (optional) isolated, persistent shell, thereby providing a continuous environment for elected modules.

### Module Directory

**Planit** accepts a single directory in which all modules reside. When it comes to the directory location, you have two options:

1. A `modules` directory located on the same level as the `planit` directory.

    ```
    MyInstaller
    ├── install
    ├── modules/
    │   └── ...
    └── planit/
    ```

2. A directory located anywhere on the system, wherein its path is passed to **Planit** as a commandline argument, or assigned to `PLAN__PATH_MODULES` in your config.

    ```sh
    "${pwd}/planit/planit" --modules 'path/to/modules'
    ```

#### Why a directory instead of YAML?

While _yaml_ is certainly the more optimal route, a parser may not always be available, which breaks a core requirement of **Planit**: _to work anywhere Bash4 is installed, within reason._

A yaml route is planned, though.

### Module Creation

> [!NOTE]
> See: [Module Naming Convention](/docs/naming-convention.md)

A module can technically be written in any language; **Planit** will attempt to execute it as is unless `PLAN__MODULE_CMD` is set, or `PLAN__MODULES_DEFAULT_CMD` if the module's executable flag is not set.


