#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

>&2 echo "Configuring wireguard"

readonly wg_iface='wg0'
readonly eth_iface="$(ip addr show | awk '/inet.*brd/{print $NF}' | grep -xFv -- "${wg_iface}" | head -n1)"
[[ -z "${eth_iface}" ]] && (>&2 echo "ERROR: Failed to autodetect ethernet interface"; exit 1)
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
    # add forwarding
    post-up iptables -A FORWARD -i ${wg_iface} -j ACCEPT; iptables -t nat -A POSTROUTING -o ${eth_iface} -j MASQUERADE; ip6tables -A FORWARD -i ${wg_iface} -j ACCEPT; ip6tables -t nat -A POSTROUTING -o ${eth_iface} -j MASQUERADE
    # after ifdown, disable forwarding
    post-down iptables -D FORWARD -i ${wg_iface} -j ACCEPT; iptables -t nat -D POSTROUTING -o ${eth_iface} -j MASQUERADE; ip6tables -D FORWARD -i ${wg_iface} -j ACCEPT; ip6tables -t nat -D POSTROUTING -o ${eth_iface} -j MASQUERADE
    # after ifdown, destroy the ${wg_iface} interface
    post-down ip link del \$IFACE
EOF

# start wireguard
systemctl restart networking
wg show "${wg_iface}"

# ensure network forwarding
>&2 echo 'Setting net.ipv4.ip_forward=1'
{
    echo "net.ipv4.ip_forward = 1"
    echo "net.ipv6.conf.all.forwarding = 1"
}> /etc/sysctl.d/wg.conf
sysctl --system
