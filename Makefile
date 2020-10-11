# Use a Bourne-compatible shell; do not rely on other shell-isms
SHELL := /bin/sh

# Directory to store empty target files
targetdir := .make

# Playbook directory and files
playbookdir := playbooks
playbooks := $(shell cd $(playbookdir) && echo *)

# Flags passed to `ansible-playbook` in test-* rules: run (v)erbosely and
# prompt for credentials (K); privilege escalation (i.e. "become") is specified
# by inventory variables
TFLAGS := -vK

# Install programs required for running this Makefile's recipes
.PHONY: setup
setup:
	dnf install -y ansible ansible-lint

# Check the syntax of altered playbooks (validity + linting)
.PHONY: check lint
check: $(foreach playbook,$(playbooks),$(targetdir)/check-$(playbook))
lint: $(foreach playbook,$(playbooks),$(targetdir)/lint-$(playbook))
define defrules
$(targetdir)/check-$1: $(playbookdir)/$1
	ANSIBLE_HOST_PATTERN_MISMATCH=ignore ansible-playbook --syntax-check $$<
	@mkdir -p $$(@D) && touch $$@
$(targetdir)/lint-$1: $(playbookdir)/$1
	ansible-lint $$<
	@mkdir -p $$(@D) && touch $$@
endef
$(foreach playbook,$(playbooks),$(eval $(call defrules,$(playbook))))

# Remove directory containing empty target files
.PHONY: clean
clean:
	rm -rf $(targetdir)

# Test a single Ansible role specified by $(ROLE)
.PHONY: test-role
test-role:
	@test "X$(ROLE)" != X || { echo >&2 'Unset variable: ROLE'; exit 1; }
	ansible-playbook -C -e role=$(ROLE) $(TFLAGS) $(playbookdir)/single-role.yml

# Test a single Ansible task list specified by $(FILE)
.PHONY: test-tasks
test-tasks:
	@test "X$(FILE)" != X || { echo >&2 'Unset variable: FILE'; exit 1; }
	ansible-playbook -C -e file=$(FILE) $(TFLAGS) $(playbookdir)/single-task-list.yml
