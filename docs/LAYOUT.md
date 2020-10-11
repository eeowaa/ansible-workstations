# Inventory

There are two inventory layouts [recommended by Ansible](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html#content-organization):

```
### STANDARD LAYOUT ###

production                # inventory file for production servers
staging                   # inventory file for staging environment

group_vars/
   group1.yml             # here we assign variables to particular groups
   group2.yml
host_vars/
   hostname1.yml          # here we assign variables to particular systems
   hostname2.yml

### ALTERNATIVE LAYOUT ###

inventories/
   production/
      hosts               # inventory file for production servers
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         hostname1.yml    # here we assign variables to particular systems
         hostname2.yml

   staging/
      hosts               # inventory file for staging environment
      group_vars/
         group1.yml       # here we assign variables to particular groups
         group2.yml
      host_vars/
         stagehost1.yml   # here we assign variables to particular systems
         stagehost2.yml
```

I like the simplicity of the standard layout, but I also like how the
alternative layout separates inventory information from the top-level content.
I've combined the two approaches and ended up with the following:

```
### CUSTOM LAYOUT ###

inventories/
   production             # inventory file for production servers
   staging                # inventory file for staging environment

   group_vars/
      group1.yml          # here we assign variables to particular groups
      group2.yml
   host_vars/
      hostname1.yml       # here we assign variables to particular systems
      hostname2.yml
```

# Playbooks and roles

Ansible has a convention of storing playbooks in the top-level directory.  In
my opinion, this convention is inconsistent with storing roles, tasks, and
other groups of files in their own directories.  This repository takes a
non-standard approach and stores all playbooks in the `playbooks` directory.

Roles are still stored in the top-level `roles` directory, which requires
modification of the `roles_path` variable in `ansible.cfg`.  From a user
perspective, nothing else needs to happen to run normally.

# Tasks

Unorganized or work-in-progress tasks go in the top-level `tasks` directory.
This is to encourage codifying systems administration tasks as I use my system
as a daily driver.  Therefore, the `tasks` directory acts as a sort of staging
environment or cache to formalize later.
