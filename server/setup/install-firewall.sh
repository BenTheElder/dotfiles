#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs persistent iptables rules
export DEBIAN_FRONTEND=noninteractive
# debian doesn't have sbin in path but iptables wll be there
export PATH="/sbin:${PATH}"

apt install -y --no-install-recommends \
    iptables-persistent

iptables -A INPUT -p udp --dport 32414 -s 192.168.0.0/24 -j ACCEPT
iptables -A INPUT -p udp --dport 32414 -s 127.0.0.0/8 -j ACCEPT
iptables -A INPUT -p udp --dport 32414 -j DROP

# https://support.plex.tv/articles/201543147-what-network-ports-do-i-need-to-allow-through-my-firewall/
# we're going to restrict the discovery
plex_discovery_ports=(
    32410
    32412
    32413
    32414
)
for port in "${plex_discovery_ports[@]}"; do
    # allow local ipv4 addresses
    iptables -A INPUT -p udp --dport "${port}" -s 192.168.0.0/24 -j ACCEPT
    iptables -A INPUT -p udp --dport "${port}" -s 127.0.0.0/8 -j ACCEPT
    iptables -A INPUT -p udp --dport "${port}" -j REJECT
    # just drop ipv6
    ip6tables -A INPUT -p udp --dport "${port}" -j REJECT
done
