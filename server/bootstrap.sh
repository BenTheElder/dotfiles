#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this scipt bootstraps my typical debian server setup

# get path to script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# elevate to root once and re-run self
if [ $UID -ne 0 ]; then
  export ORIGINAL_USER="${USER}"
  export ORIGINAL_HOME="${HOME}"
  su root "${BASH_SOURCE[0]}"
  exit
fi

SCRIPTS="${SCRIPT_DIR}/setup"
run_script_traced() {
  (set -x; source "$@")
}
run_script_traced "${SCRIPTS}"/install-packages.sh
run_script_traced "${SCRIPTS}"/automatic-upgrades.sh
run_script_traced "${SCRIPTS}"/disable-sleep.sh
run_script_traced "${SCRIPTS}"/configure-transmission.sh
