<h1 align=center>Planit 🪐</h1>
<h3 align=center>Modular Installer Framework</h3>
<br>

**Planit** is a lightweight, modular Bash4 installer framework for Linux that simplifies multi-step software installation workflows without runtime dependencies. Designed for developers who need to ship self-contained installers with minimal overhead -- all modules are executed through a single framework that adds negligible size to your release.

#### Planit does

- Orchestrates modular installations with automatic execution order, readable step names, and real-time progress feedback without external dependencies (it's all Bash and POSIX commands)

- Gracefully recovers from failures by halting on error, reporting logs, and optionally storing a resumable state on disk as a simple deterministic hash

- Supports any module language and accepts per-module configuration files, letting you write installation logic in Bash, Python, Go, or anything executable

#### Planit does not

- Provide abstraction layers for package managers, configuration templating, or conditional logic

- Support user inputs over _stdin_ or advanced workflows like parallel execution (for now), rollback functionality, or testing and validation frameworks

- Handle pre-installation dependencies before the framework runs (you manage bootstrapping in your modules)

## Getting Started

Example installation directory:

```
MyInstaller/
├── install
├── modules
│   ├── 10_bootstrap/
│   │   ├── 10_update_apt_repositories.sh
│   │   ├── 20_install_dependencies.sh
│   │   └── 30_configure_dependencies.sh
│   ├── 20_pre_install/
│   │   ├── 10_download_source_pkg.sh
│   │   └── 20_[Make_LCP-v2.x_Binary].sh
│   ├── 30_[Install_LCP-v2.x].sh
│   ├── 40_post_install/
│   │   ├── 10_[Update_RC_Config].sh
│   │   └── 20_cleaning_up.sh
│   └── 50_verify_installation.sh
└── planit.conf
```

#### Installer Setup

1. Clone the repository

    ```sh
    git clone --depth 1 https://github.com/worldshredder/planit
    ```

2. Add **Planit** to your installer directory

    ```sh
    mv planit/src/planit MyInstaller/
    ```

3. (Optional) Define custom settings in `MyInstaller/planit.conf`

    ```sh
    PLAN__STATE_ID='MyInstaller'
    PLAN__LOGGING_LEVEL='WARN'
    PLAN__MODULES_DEFAULT_TITLE='MyInstaller Module'
    ```

3. Create the main installer script `MyInstaller/install`

    ```sh
    #!/usr/bin/env bash

    pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Run planit
    "${pwd}/planit/planit"
    ```

    If your `modules` directory or `planit.conf` are located outside of the main installer directory, you must provide **Planit** their paths:

    ```sh
    "${pwd}/planit/planit" \
        --modules 'path/to/modules' \
        --config 'path/to/config'
    ```

4. (Optional) Set executable permissions

    ```sh
    chmod +x MyInstaller/install
    ```

#### Installer Execution

Installation can be initiated by simply executing the main install script

```sh
bash MyInstaller/install
```
