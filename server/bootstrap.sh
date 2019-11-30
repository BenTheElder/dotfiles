#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

run_script_traced() {
  (set -x; source "$@")
}

# this scipt bootstraps my typical debian server setup
set -x;
SCRIPT_DIR="$(cd "${BASH_SOURCE[0]}" && pwd -P)"
SCRIPTS="${SCRIPTS_DIR}/setup"
run_script_traced "${SCRIPTS}"/install-common.sh
run_script_traced "${SCRIPTS}"/automatic-upgrades.sh
run_script_traced "${SCRIPTS}"/disable-sleep.sh
run_script_traced "${SCRIPTS}"/install-plex.sh
