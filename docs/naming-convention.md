<div align=center>
    <img src='/../assets/logo.png' />
</div>
<h3 align=center>Module Naming Convention</h3>
<br>

A module's name defines two properties:

1. When the module is executed.

2. The step title displayed in the status log, unless `PLAN__MODULE_TITLE` is set.

#### Title Parsing

In order for **Planit** to parse out a title, file names must contain an integer prefix followed by an underscore, while everything after the prefix is interpreted as the step title. For example, `10_install_nodejs` would result in a title of `Install Nodejs`.

If the integer prefix is missing, **Planit** will use `PLAN__MODULES_DEFAULT_TITLE` as a fallback for the step title.

#### Title Formatting

_todo..._
