#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs and configures the transmission torrent service

apt update
apt install transmission-daemon

TRANSMISSION_USER_DROPIN="/etc/systemd/system/transmission-daemon.service.d/10-user.conf"
mkdir -p "$(dirname "${TRANSMISSION_USER_DROPIN}")"
cat <<EOF >"${TRANSMISSION_USER_DROPIN}"
[Service]
User=${ORIGINAL_USER}
EOF

systemctl daemon-reload
systemctl restart transmission-daemon
