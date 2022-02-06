#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

>&2 echo "Configuring wireguard"

readonly wg_iface='wg0'
readonly wg_conf_path="/etc/wireguard/${wg_iface}.conf"
readonly peers_conf_path="/etc/wireguard/${wg_iface}-peers.conf"

# backup existing config to backup if present
wg_current_conf=""
if [[ -f "${wg_conf_path}" ]]; then
    wg_current_conf="$(cat ${wg_conf_path})"
    mv "${wg_conf_path}" "${wg_conf_path}".bak
fi

# get wireguard private key from current configuration or generate it
if [[ -n "${wg_current_conf}" ]]; then
    wg_privkey="$(echo "${wg_current_conf}" | sed -nr 's#PrivateKey *= *([^ ]+)#\1#p')"
else
    wg_privkey="$(wg genkey)"
fi
# generate configuration
{
    echo '[Interface]'
    echo "PrivateKey = ${wg_privkey}"
    echo 'ListenPort = 51820'
    # include peers config
    # see: utils/gen-wireguard-peerconf.sh
    [ ! -f "${peers_conf_path}" ] || cat "${peers_conf_path}"
} >"${wg_conf_path}"

# ensure network interface is setup
# https://wireguard.how/server/debian/
cat <<EOF >"/etc/network/interfaces.d/${wg_iface}"
# indicate that ${wg_iface} should be created when the system boots, and on ifup -a
auto ${wg_iface}
# describe ${wg_iface} as an IPv4 interface with static address
iface ${wg_iface} inet static
    # static IP address
    address 10.0.2.1/24
    # before ifup, create the device with this ip link command
    pre-up ip link add \$IFACE type wireguard
    # before ifup, set the WireGuard config from earlier
    pre-up wg setconf \$IFACE /etc/wireguard/\$IFACE.conf
    # after ifdown, destroy the wg0 interface
    post-down ip link del \$IFACE
EOF

# start wireguard
systemctl restart networking
wg show "${wg_iface}"

# ensure network forwarding
>&2 echo 'Setting net.ipv4.ip_forward=1'
echo 'net.ipv4.ip_forward=1' >/etc/sysctl.d/forward-traffic.conf
sysctl -p
