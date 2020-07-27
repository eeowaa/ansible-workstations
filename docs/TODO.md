# TODO: Install software based on environmental needs and restrictions

For example:
- Graphical environment / console only
  - Can futher divide into X11 / Wayland
- Full / minimal installation
- Permit / deny nonfree software

Investigate using variables to achieve this:
- <https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html>
- <https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#splitting-out-vars>

Investigate using tags to achieve this.

# TODO: Have some mechanism to perform updates

Same as above:
- Variables (e.g. -e update=true)
- Tags (e.g. -t update)

# TODO: Use `dconf` Ansible module to implement GNOME settings

- <https://fedoramagazine.org/using-ansible-setup-workstation/>
- Do this in `gnome-desktop` role.
- Might want to change things manually and do a before/after diff of the dconf
  database.  For example:
  ``` bash
  dconf dump / >/tmp/before
  ...manually change setting...
  dconf dump / >/tmp/after
  diff -u /tmp/{before,after}
  ```

# TODO: Improve linting

1. Use [`yamllint`](https://github.com/adrienverge/yamllint)
2. Lint roles in addition to playbooks <https://github.com/ansible/ansible-lint#linting-playbooks-and-roles>

# TODO: Create a top-level `bin` directory with helper scripts

1. Move `bootstrap` into `bin` and modify appropriately
2. Add a script to report default variables that have not been overridden
   - `bin/default-vars`
3. Add a script to ignore (`git update-index --skip-worktree`) inventory files
   that might be updated to contain sensitive information
   - `bin/lock-inventory`: hide inventory updates from Git
   - `bin/unlock-inventory`: re-enable tracking of inventory worktree

# TODO: Write `docs/INVENTORY.md`

Explain inventory handling
- Default inventory provided
  - One group: `workstations`
  - One host: `localhost`
- Other groups and hosts can be added, but should not be committed to Git if
  that information is sensitive and the repo is to be globally published
  - Use the `bin/lock-inventory` script to lock it down
  - Consider using [dynamic inventory](https://docs.ansible.com/ansible/latest/user_guide/intro_dynamic_inventory.html) instead

# TODO: Write `docs/VARS.md`

Explain variable handling
- Role `defaults` should always be manually verified; frequently overridden
  - Place overrides in a variables file ignored by git
  - Top-level definitions should be preferred for ease of management
- Can be placed in `inventories/group_vars` and/or `inventories/host_vars`
  - Can prevent versioning by running `bin/lock-inventory`
  - These two directories reside in the top level
    - The `all.yml` files apply everywhere, if that's what you want
    - Probably better to be group- and/or host-specific most of the time

# TODO: Add role documentation from fedora-start.md

Each role directory should have a `README.md` describing the role.  For now,
this information doesn't need to be too detailed, and should just be copied
from the external `fedora-start.md` document I've been maintaining separately.
