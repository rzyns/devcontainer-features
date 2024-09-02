#!/bin/bash

# shellcheck source=activate_on-bash.sh
source "$(dirname "${BASH_SOURCE[0]}")/activate_on-bash.sh"

check "execute installed command with mise (non-login shell)" zsh -c 'mise exec eza -- eza --version > /dev/null'
check "execute installed command (non-login shell)" zsh -c 'eza --version > /dev/null'
check "execute installed command (login shell)" zsh -l -c 'eza --version > /dev/null'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
