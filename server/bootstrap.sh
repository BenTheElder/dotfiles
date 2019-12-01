#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

run_script_traced() {
  (set -x; source "$@")
}

elevate() {
  if [ $UID -ne 0 ]; then
    export ORIGINAL_USER="${USER}"
    su root "${BASH_SOURCE[0]}"
  fi
}

# this scipt bootstraps my typical debian server setup
set -x;
elevate
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPTS="${SCRIPT_DIR}/setup"
run_script_traced "${SCRIPTS}"/install-common.sh
run_script_traced "${SCRIPTS}"/automatic-upgrades.sh
run_script_traced "${SCRIPTS}"/disable-sleep.sh
run_script_traced "${SCRIPTS}"/install-plex.sh
run_script_traced "${SCRIPTS}"/install-transmission.sh
