# Use a Bourne-compatible shell; do not rely on other shell-isms
SHELL := /bin/sh

# Directory to store empty target files
targetdir := .make

# Playbook directory and files
playbookdir := playbooks
playbooks := $(notdir $(wildcard $(playbookdir)/*.yml))

# Default flags passed to `ansible-playbook`: run (v)erbosely and prompt for
# credentials (K); privilege escalation (i.e. "become") is specified by
# inventory variables. Override with -vKC to perform a dry run.
ANSIBLE_FLAGS := -vK

# Install programs and roles required for running this Makefile's recipes
.PHONY: setup
setup:
	dnf install -y ansible ansible-lint
	if test -f requirements.yml; then ansible-galaxy install -r requirements.yml; fi

# Check the syntax of altered playbooks (validity + linting)
.PHONY: check lint
check: $(foreach playbook,$(playbooks),$(targetdir)/check-$(playbook))
lint: $(foreach playbook,$(playbooks),$(targetdir)/lint-$(playbook))
define defrules
$(targetdir)/check-$1: $(playbookdir)/$1
	@echo '! Checking syntax of playbook: $$<'
	ANSIBLE_HOST_PATTERN_MISMATCH=ignore ansible-playbook --syntax-check $$<
	@mkdir -p $$(@D) && touch $$@
$(targetdir)/lint-$1: $(playbookdir)/$1
	@echo '! Linting playbook: $$<'
	ansible-lint $$<
	@mkdir -p $$(@D) && touch $$@
endef
$(foreach playbook,$(playbooks),$(eval $(call defrules,$(playbook))))

# Remove directory containing empty target files
.PHONY: clean
clean:
	rm -rf $(targetdir)

# Run a $(TARGET) role in isolation
.PHONY: role
ifeq (role,$(findstring role,$(MAKECMDGOALS)))
    export TARGET
    ifeq (,$(TARGET))
        $(error Unset variable: TARGET)
    else ifneq (0,$(shell test -d "roles/$${TARGET}"; echo $$?))
        $(error Not a directory: roles/$(TARGET))
    endif
endif
role:
	ansible-playbook -e target="$${TARGET}" $(ANSIBLE_FLAGS) '$(playbookdir)/isolated-role.yml'

# Run all tasks defined in a $(TARGET) file
.PHONY: tasks
ifeq (tasks,$(findstring tasks,$(MAKECMDGOALS)))
    export TARGET
    ifeq (,$(TARGET))
        $(error Unset variable: TARGET)
    else ifneq (0,$(shell test -f "$${TARGET}"; echo $$?))
        $(error Not a regular file: $(TARGET))
    endif
    override TARGET := $(shell realpath --relative-to='$(playbookdir)' "$${TARGET}")
endif
tasks:
	ansible-playbook -e target="$${TARGET}" $(ANSIBLE_FLAGS) '$(playbookdir)/isolated-tasks.yml'
