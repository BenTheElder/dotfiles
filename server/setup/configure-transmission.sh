#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs and configures the transmission torrent service
export DEBIAN_FRONTEND=noninteractive
# TODO: make this configurable
TRANSMISSION_DOWNLOAD_DIR="/mnt/storage/plex/download"

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
sed -i 's#"rpc-bind-address":.*#"rpc-bind-address": "127.0.0.1",#' "${ORIGINAL_HOME}"/.config/transmission-daemon/settings.json

# disable dht and pex, we'll be using our own trackers / peers
sed -i 's#"dht-enabled":.*#"dht-enabled": false,#' "${ORIGINAL_HOME}"/.config/transmission-daemon/settings.json
sed -i 's#"pex-enabled":.*#"pex-enabled": false,#' "${ORIGINAL_HOME}"/.config/transmission-daemon/settings.json

# set download dir
sed -i 's#"download-dir":.*#"download-dir": "'"${TRANSMISSION_DOWNLOAD_DIR}"'",#' "${ORIGINAL_HOME}"/.config/transmission-daemon/settings.json

# ensure /etc/hosts entry for checking if port is open
# https://github.com/transmission/transmission/issues/407#issuecomment-377573705
portcheck_host_line='87.98.162.88 portcheck.transmissionbt.com'
if ! grep -Fxq "${portcheck_host_line}" /etc/hosts; then
  echo "${portcheck_host_line}" >> /etc/hosts
fi

# restart transmission with latest settings
systemctl daemon-reload
systemctl start transmission-daemon
