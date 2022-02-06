#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script configures CoreDNS

corefile_path='/etc/coredns/Corefile'

cat <<EOF >"${corefile_path}"
:53 {
    forward . tls://9.9.9.9 tls://149.112.112.112 tls://2620:fe::fe tls://2620:fe::9 {
        tls_servername dns.quad9.net
        policy sequential
    }
    # TODO: tune cache
    cache
    error
}
EOF

# ensure coredns user
echo 'u coredns - "CoreDNS is a DNS server that chains plugins " /' >/usr/lib/sysusers.d/coredns.conf
systemd-sysusers

# configure systemd
# https://github.com/coredns/deployment/blob/39c9f7ed7640f86fa0fb6ba06a88e9afa830b306/systemd/coredns.service
cat <<EOF >/etc/systemd/user/coredns.service
[Unit]
Description=CoreDNS DNS server
Documentation=https://coredns.io
After=network.target

[Service]
PermissionsStartOnly=true
LimitNOFILE=1048576
LimitNPROC=512
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true
User=coredns
WorkingDirectory=~
ExecStart=/usr/local/bin/coredns -conf=${corefile_path}
ExecReload=/bin/kill -SIGUSR1 $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable coredns.service
