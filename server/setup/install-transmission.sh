#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs and configures the transmission torrent service
# TODO: make this configurable
TRANSMISSION_DOWNLOAD_DIR="/mnt/storage/plex/download"

apt update
apt install transmission-daemon

# stop the daemon before we modify config (required)
systemctl stop transmission-daemon

# ensure that it runs as our user
TRANSMISSION_USER_DROPIN="/etc/systemd/system/transmission-daemon.service.d/10-user.conf"
mkdir -p "$(dirname "${TRANSMISSION_USER_DROPIN}")"
cat <<EOF >"${TRANSMISSION_USER_DROPIN}"
[Service]
User=${ORIGINAL_USER}
EOF

# only bind the web ui to localhost
sed -i "${ORIGINAL_HOME}"/.config/transmission-daemon/settings.json 's/"rpc-bind-address":.*/"rpc-bind-address": "127.0.0.1",'

# disable dht and pex, we'll be using our own trackers / peers
sed -i "${ORIGINAL_HOME}"/.config/transmission-daemon/settings.json 's/"dht-enabled":.*/"dht-enabled": false,'
sed -i "${ORIGINAL_HOME}"/.config/transmission-daemon/settings.json 's/"pex-enabled":.*/"pex-enabled": false,'

# set download dir
sed -i "${ORIGINAL_HOME}"/.config/transmission-daemon/settings.json 's/"download-dir":.*/"download-dir": "'"${TRANSMISSION_DOWNLOAD_DIR}"'",'

# restart transmission with latest settings
systemctl daemon-reload
systemctl start transmission-daemon
