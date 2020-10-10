# Reporting package operation history

Consider piping the following commands to a pager.

## `dnf` command line operations

``` sh
dnf history list
```

## Indirect `dnf` operations (e.g. PackageKit, Ansible)

``` sh
dnf history info `
    dnf history list |
    awk -F\| 'NR > 2 && $2 !~ /^ [^ ]/ { print $1 }'
`
```
