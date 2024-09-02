#!/bin/bash

set -euo pipefail

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "mise is intalled" bash -c 'which mise'
check "installs eza" bash -c 'mise use -y -g eza'
check "can run eza with mise (non-login shell)" bash -c 'mise exec eza -- eza'
check "execute installed command (non-login shell)" bash -c 'if eza --version ; then false; else true; fi'
check "execute installed command (login shell)" bash -l -c 'if eza --version ; then false; else true; fi'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
