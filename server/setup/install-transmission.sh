#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs and configures the transmission torrent service

apt update
apt install transmission-daemon

cat <<EOF >/etc/systemd/system/transmission-daemon.service.d/10-user.conf
User=${ORIGINAL_USER}
EOF

systemctl daemon-reload
systemctl restart transmission-daemon
