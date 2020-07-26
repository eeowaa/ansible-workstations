# Use a Bourne-compatible shell; do not rely on other shell-isms
SHELL := /bin/sh

# Directory to store empty target files
targetdir := .make

# Ansible playbooks we care about
playbooks := $(wildcard *.yml)

# Install programs required for running this Makefile's recipes
.PHONY: setup
setup:
	dnf install -y ansible ansible-lint

# Check the syntax of altered playbooks (validity + linting)
.PHONY: check lint
check: $(foreach playbook,$(playbooks),$(targetdir)/check-$(playbook))
lint: $(foreach playbook,$(playbooks),$(targetdir)/lint-$(playbook))
define defrules
$(targetdir)/check-$1: $1
	ANSIBLE_HOST_PATTERN_MISMATCH=ignore ansible-playbook --syntax-check $1
	@mkdir -p $(targetdir) && touch $(targetdir)/check-$1
$(targetdir)/lint-$1: $1
	ansible-lint $1
	@mkdir -p $(targetdir) && touch $(targetdir)/lint-$1
endef
$(foreach playbook,$(playbooks),$(eval $(call defrules,$(playbook))))

# Remove directory containing empty target files
.PHONY: clean
clean:
	rm -rf $(targetdir)


# Test a single Ansible $(ROLE), passing $(TFLAGS) to ansible-playbook:
# (b)ecome the root user, prompt for credentials (K), and run (v)erbosely
TFLAGS := -vK
.PHONY: test
test:
	@test "X$(ROLE)" != X || { echo >&2 'Unset variable: ROLE'; exit 1; }
	ansible-playbook -C -e role=$(ROLE) $(TFLAGS) single-role.yml
