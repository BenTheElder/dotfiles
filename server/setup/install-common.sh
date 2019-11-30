#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs some common utilities

# enable non-free and contrib repos (necessary for things like nvidia drivers)
add-apt-repository non-free
add-apt-repository contrib

# update and then install utils
apt update
# TODO ...
apt install -y --no-install-recommends curl
