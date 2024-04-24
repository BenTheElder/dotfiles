#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# This script installs server packages including:
# - transmission
# - plex
# - zfs
# - rsync
# - screen
# .. and dependencies
# it also enables related repos and backports
export DEBIAN_FRONTEND=noninteractive

# apt update helper
apt_update() {
    >&2 echo "INFO: updating apt"
    apt update || >&2 echo "WARNING: Failed to update apt"
}

# apt install helper
apt_install() {
    apt install -y --no-install-recommends "$@"
}

# install packages used for the rest of the setup
>&2 echo "INFO: installing base packages"
apt_update
apt_install \
    curl software-properties-common

# enable backports
codename="$(sed -nr 's#VERSION_CODENAME=(.*)#\1#p' /etc/os-release)"
codename_backports="${codename}-backports"
>&2 echo "INFO: Enabling ${codename_backports}"
add-apt-repository "deb http://deb.debian.org/debian ${codename_backports:?} main contrib non-free non-free-firmware"

# enable non-free and contrib repos (necessary for things like nvidia drivers)
>&2 echo "INFO: Enabling non-free and contrib"
add-apt-repository "deb http://deb.debian.org/debian ${codename:?} main non-free non-free-firmware contrib"

# add plex repo
# https://support.plex.tv/articles/235974187-enable-repository-updating-for-supported-linux-server-distributions/
echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -

# install packages
apt_update
>&2 echo "INFO: Installing remaining packages"
apt_install \
    "linux-headers-$(uname -r)" \
    plexmediaserver \
    rsync screen \
    transmission-daemon \
    wireguard qrencode dnsutils
# backports packages
apt_install -t "${codename_backports:?}" \
    dkms spl-dkms \
    zfs-dkms zfsutils-linux
