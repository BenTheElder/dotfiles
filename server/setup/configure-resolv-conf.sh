#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script ensures we don't wind up with a DNS loop from DHCP
# since we'll be providing DNS from this server ...

# ensure NetworkManager won't manage /etc/resolv.conf
cat <<EOF >/etc/NetworkManager/conf.d/90-dns-none.conf
[main]
dns=none
EOF
systemctl reload NetworkManager

# ensure /etc/resolv.conf includes the DNS server we'll be
# running ourselves AND a reasonable fallback in case we break it
cat <<EOF >/etc/resolv.conf
nameserver 127.0.0.1
nameserver 9.9.9.9
EOF
