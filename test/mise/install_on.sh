#!/bin/bash

set -euo pipefail

source dev-container-features-test-lib

check "mise is intalled" bash -c 'which mise'
check "run eza" bash -lc 'eza --version'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
