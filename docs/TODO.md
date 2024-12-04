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

# WIP: Have some mechanism to perform updates

Same as above:
- Variables (e.g. -e update=true)
  - Currently using this for aws-client role
- Tags (e.g. -t update)

# WIP: Use `dconf` Ansible module to implement GNOME settings

- <https://fedoramagazine.org/using-ansible-setup-workstation/>
- Do this in `gnome-desktop` role.
- Might want to change things manually and do a before/after diff of the dconf
  database.  For example:
  ``` bash
  dconf dump / >/tmp/before
  ...manually change setting...
  dconf dump / >/tmp/after
  diff -u /tmp/{before,after}

  # Alternatively (https://askubuntu.com/questions/72070/how-do-i-change-dconf-keys-without-a-gui-for-a-post-install-script)
  dconf watch /
  ...manually change setting...
  ```

# TODO: Improve linting

1. Use [`yamllint`](https://github.com/adrienverge/yamllint)
2. Lint roles in addition to playbooks <https://github.com/ansible/ansible-lint#linting-playbooks-and-roles>

# WIP: Create a top-level `bin` directory with helper scripts

1. [DONE] Move `bootstrap` into `bin` and modify appropriately
2. [WIP] Add a script to report default variables that have not been overridden
   - `bin/default-vars`
3. [DONE] Add a script to ignore (`git update-index --skip-worktree`) inventory
   files that might be updated to contain sensitive information
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

# TODO: Do not rely on Fedora base system

Use `dnf history info 1` on your Fedora system to see the base package list.
If you always want one of these packages on the systems you run the playbooks
on, you should explicitly specify those packages.

# TODO: Do not require the user to enter a password when checking roles

`make check-<role>` currently requires the user to enter a password on the
command prompt.  This is unnecessary and disruptive.  However, if `dnf` is not
run with root permissions, it fails with an error message.

One workaround would be to use `fakeroot(1)` to simulate running as root
without actually elevating our permissions.  Unfortunately, this adds another
prerequisite to be installed in the `setup` target of the Makefile.  Another
option would be to investigate running `dnf` without root permissions.

See <https://github.com/rootless-containers/rootlesskit> for a Linux-native
implementation of fakeroot.

# TODO: Fix playbooks that fail in `make check`

Currently, there are some failures due to required variables missing.  Either
pass in variables using `-e var=value` or set default variables.

# TODO: Attempt to use `%` type rules in the Makefile

The `$(foreach playbook,$(playbooks),$(eval $(call defrules,$(playbook))))`
magic is pretty cool, but I'd prefer to replace the deep magic with something
more readable.

# TODO: Clone `stow-dotfiles` if this is a developer workstation

# TODO: Install Doom Emacs

``` sh
#!/bin/sh

### Install dependencies {{{

# Required dependencies
brew install git ripgrep

# Optional dependencies
brew install findutils coreutils fd

# Installs clang
xcode-select --install

### }}}
### Install Emacs {{{

# Let's go for the most Doom-compatible option
brew tap d12frosted/emacs-plus
brew install emacs-plus
ln -s /usr/local/opt/emacs-plus/Emacs.app /Applications/Emacs.app

### }}}
### Install Doom {{{

# Create directories for Doom Emacs and private config
mkdir -p $HOME/.config/emacs $HOME/.config/doom

# Clone Doom Emacs
git clone https://github.com/hlissner/doom-emacs $HOME/.config/emacs

# So we don't have to write $HOME/.emacs.d/bin/doom every time
PATH="$HOME/.emacs.d/bin:$PATH"

# The init.example.el file contains an example doom! call, which tells Doom what
# modules to load and in what order.
cp $HOME/.config/emacs/init.example.el $HOME/.config/doom/init.el
cp $HOME/.config/emacs/core/templates/config.example.el $HOME/.config/doom/config.el
cp $HOME/.config/emacs/core/templates/packages.example.el $HOME/.config/doom/packages.el

# You might want to edit $HOME/.doom.d/init.el here and make sure you only have the
# modules you want enabled.

# Then synchronize Doom with your config:
doom sync

# If you know Emacs won't be launched from your shell environment (e.g. you're
# on macOS or use an app launcher that doesn't launch programs with the correct
# shell) then create an envvar file to ensure Doom correctly inherits your shell
# environment.
#
# If you don't know whether you need this or not, there's no harm in doing it
# anyway. `doom install` will have prompted you to generate one. If you
# responded no, you can generate it later with the following command:
doom env

# Lastly, install the icon fonts Doom uses:
emacs --batch -f all-the-icons-install-fonts
# On Windows, `all-the-icons-install-fonts` will only download the fonts, you'll
# have to install them by hand afterwards!

### }}}
```
