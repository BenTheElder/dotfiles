#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs zfs
export DEBIAN_FRONTEND=noninteractive

# enable backports for zfs
codename_backports="$(lsb_release -cs)-backports"
echo "Enabling ${codename_backports}"
add-apt-repository "deb http://deb.debian.org/debian ${codename_backports:?} main contrib non-free"

# update and then install utils, do not fail on updating ...
apt update || echo "WARNING failed to update apt"

# install kernel headers and zfs
# https://wiki.debian.org/ZFS#Installation
apt install -yq --no-install-recommends "linux-headers-$(uname -r)"
apt install -yq --no-install-recommends -t "${codename_backports:?}" \
    dkms spl-dkms \
    zfs-dkms zfsutils-linux
