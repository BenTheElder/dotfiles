#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# configures a wireguard peer
# the server must be configured first (server/setup/configure-wireguard.sh)
>&2 echo "Configuring wireguard peer"

# TODO: should be configurable or auto-increment for additional peers
wg_client_ip='10.0.2.2/32'
readonly wg_iface='wg0'
readonly peers_conf_path="/etc/wireguard/${wg_iface}-peers.conf"
readonly wg_server_ip='10.0.2.1'

# get keys
wg_client_priv_key="$(wg genkey)"
wg_client_pub_key="$(echo ${wg_client_priv_key} | wg pubkey)"

# get server info
server_public_key="$(wg show "${wg_iface}" public-key)"
# TODO: better way to get public IP portably?
server_public_ip="$(curl https://ipinfo.io/ip)"
server_public_address="${server_public_ip}:51820"

# generate config
# TODO: DNS, IPv6
>&2 echo "Use the following config on your client"
gen_conf() {
    echo '[Interface]'
    echo "PrivateKey = ${wg_client_priv_key}"
    echo "Address    = ${wg_client_ip}"
    echo ''
    echo "[Peer]"
    echo "PublicKey  = ${server_public_key}"
    echo "AllowedIPs = 0.0.0.0/0"
    echo "Endpoint   = ${server_public_address}"
    # NOTE: second IP is router fallback, which also routes through the server primarily
    echo "DNS        = ${wg_server_ip},10.0.0.1"
}
conf="$(gen_conf)"
echo "${conf}"
>&2 echo ''
>&2 echo "Or use the QR code:"
echo "${conf}" | qrencode -t ansiutf8

# generate server peer config
>&2 echo ''
>&2 echo "Adding peer config to ${peers_conf_path}"
{
    echo "[Peer]"
    echo "PublicKey  = ${wg_client_pub_key}"
    echo "AllowedIPs = ${wg_client_ip}"
}>>"${peers_conf_path}"

>&2 echo "Now you should run server/bootstrap.sh to apply changes to server config."
