# NAME

ansible-workstations - Ansible playbooks and roles to provision workstations

# SYNOPSIS

``` sh
# OPTIONAL: Hide local inventory modifications from Git
bin/lock-inventory

# OPTIONAL: Edit workstations group (member hosts and host/group variables)
vi inventories/...

# Install required tools, perform initial updates, and reboot host(s)
sudo bin/bootstrap

# Provision host(s) using an appropriate playbook
ansible-playbook -vK playbooks/home-computer.yml
```

# DESCRIPTION

This goal of this **work-in-progress** repository is to have a set of Ansible
playbooks for provisioning my personal and professional workstations.
Fedora 34 will be the first supported operating system, with Amazon Linux 2
following close behind.

# SEE ALSO

- [`docs` directory](docs)
