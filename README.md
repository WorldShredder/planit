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

- Support advanced workflows like parallel execution (for now), rollback functionality, or testing and validation frameworks

- Handle pre-installation dependencies before the framework runs (you manage bootstrapping in your modules)

## Getting Started

Example installation directory:

```
installer/
└── modules
    ├── 10_prepare_environment.sh
    ├── 20_update_apt_repositories.sh
    ├── 30_boostrapping
    │   ├── 10_install_dependencies.sh
    │   ├── 20_configure_dependencies.sh
    │   └── 30_bootstrap_environment.sh
    ├── 40_download_source_pkg.sh
    ├── 50_[Configure_and_Make_LCP-v2.x].sh
    ├── 60_[Install_LCP-v2.x].sh
    └── 70_post_install
        ├── 10_[Update_RC_Config].sh
        └── 20_cleaning_up.sh
```

1. Clone the repository

    ```sh
    git clone --depth 1 https://github.com/worldshredder/planit
    ```

2. Add **Planit** to your installer directory

    ```sh
    mv planit/src/planit path/to/installer
    ```

3. Create the main installer script `installer/install`

    ```sh
    #!/usr/bin/env bash

    pwd="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    "${pwd}/planit/planit" --modules "${pwd}/modules"
    ```



