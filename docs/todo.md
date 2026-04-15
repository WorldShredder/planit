<h1 align=center>Planit</h1>
<h3 align=center>Todo List</h3>
<br>

- [ ] Derive module titles from directory/file names.

- [ ] Implement substep feature.

- [ ] Store installer state on disk for install recovery.

- [ ] Optional configuration and planning through _yaml_ like **Ansible**.

    This will likely need something other than `yq`, e.g., **Python**. Require as little software as possible to use **Planit**.

- [ ] Create test cases.

- [ ] Handle requests on stdin (maybe?)

    This feature would be outside the scope of **Planit** but would be nice to have. Maybe allow bringing background process into foreground on an alt screen.

- [ ] Detect and alert stalled module.

    If stdin is handled with control provided by a foreground process in an alt screen, detection could offer a resolution route via the same system.
