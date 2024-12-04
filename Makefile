# Use a Bourne-compatible shell with the typical prefix for tracing output
SHELL := /bin/sh
null :=
space := $(null) $(null)
export PS4 := +$(space)

# Directory to store empty target files for Makefile rules
export CACHEDIR := .cache

# Playbook directory and files
playbookdir := playbooks
playbooks := $(notdir $(wildcard $(playbookdir)/*.yml))

# Default flags passed to ansible-playbook: run (v)erbosely and prompt for
# credentials (K); privilege escalation (i.e. "become") is specified by
# inventory variables. Override with -vKC to perform a dry run.
ANSIBLE_FLAGS := -vK

# Install programs and roles required for running this Makefile's recipes
.PHONY: setup
setup:
	dnf install -y ansible ansible-lint
	if test -f requirements.yml; then ansible-galaxy install -r requirements.yml; fi

# Validate the syntax of new and updated playbooks in $(playbookdir)
check_targets := $(addprefix $(CACHEDIR)/check-,$(playbooks))
$(check_targets): $(CACHEDIR)/check-%: $(playbookdir)/%
	@printf "! Checking syntax of playbook: $<\n$${PS4}"
	ANSIBLE_HOST_PATTERN_MISMATCH=ignore ansible-playbook --syntax-check $<
	@mkdir -p $(@D) && touch $@
.PHONY: check
check: $(check_targets)

# Perform static analysis of new and updated playbooks in $(playbookdir)
lint_targets := $(addprefix $(CACHEDIR)/lint-,$(playbooks))
$(lint_targets): $(CACHEDIR)/lint-%: $(playbookdir)/%
	@printf "! Linting playbook: $<\n$${PS4}"
	ansible-lint $<
	@mkdir -p $(@D) && touch $@
.PHONY: lint
lint: $(lint_targets)

# Remove hidden artifacts (empty target files) generated by this Makefile
clean_targets := $(addprefix clean-,$(playbooks))
.PHONY: $(clean_targets)
$(clean_targets): clean-%: $(playbookdir)/%
	@set -x; \
	rm -f "$${CACHEDIR}/check-$*" "$${CACHEDIR}/lint-$*"
.PHONY: clean
clean: $(clean_targets)
	@set -x; \
	rmdir "$${CACHEDIR}" 2>/dev/null || :

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
	@set -x; \
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
	@set -x; \
	ansible-playbook -e target="$${TARGET}" $(ANSIBLE_FLAGS) '$(playbookdir)/isolated-tasks.yml'
