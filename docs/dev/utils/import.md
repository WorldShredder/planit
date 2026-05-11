<div align=center>
    <img src='/../assets/logo.png' />
</div>
<h1 align=center>Devolper Docs</h1>
<h3 align=center>utils/import</h3>
<br>
<div align=center>

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/WorldShredder/planit)

</div>
<br>

The **import** utility is used to bootstrap **Planit** libraries to provide on-demand imports via `source`. It also provides rudimentary dependency wiring through its very minimal API.

## Bootstrapping

Bootstrapping a library involves sourcing `utils/import.sh`, passing the library's function namespace as param `$1` and `$@` as param `$2` to provide on-demanding sourcing for other modules and scripts:

```sh
# lib/my_lib.sh
source "${PLAN__PATH_ROOT}/utils/import.sh" Plan::my_lib "$@"
```

This sets up a minimal enviroment for the library to leverage using import utility functions. Of note here is the `__C__` components array which is optionally loaded from a comma-separated string of library-defined modules, and which is responsible for the dynamic, on-demand loading capabilities.

### Environment

- #### `__NAMESPACE__` _(string)_

    A string defining the library's function namespace. This variable is defined during the bootstrap phase by `$1` to `import.sh`.

- #### `__OVERWRITE__` _(bool)_

    A boolean value which determines redeclaration behavior for the library, and is defined using the `-o|--overwrite` commandline option. If `true`, permits redeclaration of previously imported library components. Defaults to `false`.

- #### `__C__` _(array)_

    An array of library components to declare on-demand, and is defined using the `-c|--component` commandline option. If this array is empty, the library will be lazy-loaded.

    Example:

    ```sh
    # dynamically loads Plan::my_lib.foo and Plan::my_lib.bar
    source "${PLAN__PATH_ROOT}/lib/my_lib" --component foo,bar
    ```

### Options

- #### `-c|--component COMPONENT[,...]` _(string)_

    A comma-separated list of components to import when sourcing the library. This corresponds to the `__C__` environment array.

- #### `-o|--overwrite`

    Enables redeclaration of previously imported library components.

## API

- ### `Plan::import [OPTIONS ...] COMPONENT`

    This function checks the current environment for a given library function under `__NAMESPACE__` and returns a non-zero exit code if the library function is already declared. If this function's `-o|--overwrite` option is given, or if `__OVERWRITE__` is `true`, this function will return a zero exit code regardless of redeclaration status.

    ### Positional Args

    1. #### `COMPONENT`

        The component to check for under `__NAMESPACE__`. If `COMPONENT` starts with a `+`, it is considered a _component group_ and everything after `+` is the _group identifier_. In this mode, `Plan::import` will attempt to declare the identifier as a function under `__NAMESPACE__` if it doesn't already exist.

        A _component group_ allows groups of functions and variables with arbitrary names to take advantage of the dynamic loading capabilities.

    ### Options

    - #### `-r|--require COMPONENT[,...]` _(string)_

        A comma-separated list of library components required by the target component. This is necessary for library components that rely on the same independent components within the library. Reqired components extend the `__C__` array and must be defined after the component requiring them.

    - #### `-n|--namespace NAMESAPCE` _(string)_

        The namespace to check under. This overrides the value of `__NAMESPACE__` defined during the bootstrap phase.

    - #### `-o|--overwrite`

        Return zero exit code if `COMPONENT` and required components have already been declared. This overrides the value of `__OVERWRITE__` defined during the bootstrap phase.

- ### `Plan::import.clean`

    Cleans up environment variables and functions defined during the bootstrap phase. This function should be called at the end of each library which utilizes `import.sh`.

## Example

- `lib/foo.sh`

    ```sh
    #!/usr/bin/env bash

    source "${PLAN__PATH_ROOT}/utils/import.sh" Plan::foo "$@"

    # Dependent Component
    if Plan::import --require 'md5,sha256' -- 'hash'
    then
        Plan::foo.hash() {
            local algo="$1"; shift
            case "$algo" in
                md5) Plan::foo.md5 "$*";;
                sha) Plan::foo.sha256 "$*";;
                *) return 1;;
            esac
        }
    fi

    # Standard Components
    if Plan::import -- 'md5'; then
        Plan::foo.md5() { md5sum <<< "$*" | cut -d' ' -f1; }
    fi

    if Plan::import -- 'sha256'; then
        Plan::foo.sha256() { sha256sum <<< "$*" | cut -d' ' -f1; }
    fi

    # Component Group
    if Plan::import -- '+colors'; then
        r='\033[31m'
        g='\033[32m'
        b='\033[34m'
    fi
    ```

- `bar.sh`

    ```sh
    #!/usr/bin/env bash

    # Lazy Loading
    source "${PLAN__PATH_ROOT}/lib/foo.sh"

    # On-Demand Loading (Chained: hash->md5,sha256)
    source "${PLAN__PATH_ROOT}/lib/foo.sh" --component 'hash'
    Plan::foo.hash 'md5' 'Hello, World!'
    Plan::foo.md5 'Hello, World!'
    Plan::foo.sha256 'Hello, World!'
    [ -n "${r}${g}${b}" ] # returns false

    # On-Demand Loading (Unchained: +colors)
    source "${PLAN__PATH_ROOT}/lib/foo.sh" --component '+colors'
    [ -n "${r}${g}${b}" ] # returns true
    declare -F 'Plan::foo.colors' # returns true
    ```

