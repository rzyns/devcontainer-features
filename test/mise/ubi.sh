#!/bin/bash

set -euo pipefail

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "mise is intalled" bash -c 'which mise'
check "installs ubi:eza" bash -c 'MISE_EXPERIMENTAL=1 mise use -y -g ubi:eza-community/eza'
check "execute installed command" bash -c 'eval "$(mise env --shell bash)" && eza --version | grep "https://github.com/eza-community/eza"'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
