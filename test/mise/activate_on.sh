#!/bin/bash

set -euo pipefail

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

not_login_shell () {
	! shopt login_shell > /dev/null
}

not_interactive_shell () {
	if [[ $- == *i* ]]; then
		false
	else
		true
	fi
}

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "mise is intalled" bash -c 'which mise'
check "installs eza" bash -c 'mise use -y -g eza'
check "execute installed command" bash -l -c 'eza --version > /dev/null'

check "Should not be login shell" not_login_shell
check "Should not be interactive shell" not_interactive_shell

check "execute installed command with mise (non-login shell)" mise exec eza -- eza --version > /dev/null
check "execute installed command (non-login shell)" eza --version > /dev/null
check "execute installed command (login shell)" bash -l -c 'eza --version > /dev/null'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
