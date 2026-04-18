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

1. Clone the repository

    ```sh
    git clone --depth 1 https://github.com/worldshredder/planit
    ```

