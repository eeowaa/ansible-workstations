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
