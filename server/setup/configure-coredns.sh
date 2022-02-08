#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script configures CoreDNS

# setup coreDNS config paths
coredns_config_dir='/etc/coredns'
if [[ ! -d "${coredns_config_dir}" ]]; then
    mkdir "${coredns_config_dir}"
fi
corefile_path="${coredns_config_dir}/Corefile"
block_hosts_path="${coredns_config_dir}/hosts"

# ensure the file exists, we will actually pull it regularly with
# a systemd timer
touch "${block_hosts_path}"

# CoreDNS config
cat <<EOF >"${corefile_path}"
.:53 {
    hosts /etc/coredns/hosts {
        reload 5s
        fallthrough
    }
    forward . tls://9.9.9.9 tls://149.112.112.112 tls://2620:fe::fe tls://2620:fe::9 {
        tls_servername dns.quad9.net
        policy sequential
    }
    # TODO: tune cache
    cache
    log
    errors
}
EOF

# ensure coredns user
echo 'u coredns - "CoreDNS is a DNS server that chains plugins " / /usr/sbin/nologin' >/usr/lib/sysusers.d/coredns.conf
systemd-sysusers

# configure systemd
# https://github.com/coredns/deployment/blob/39c9f7ed7640f86fa0fb6ba06a88e9afa830b306/systemd/coredns.service
cat <<EOF >/etc/systemd/system/coredns.service
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
ExecStart=/usr/local/bin/coredns -conf=${corefile_path}
ExecReload=/bin/kill -SIGUSR1 \$MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# add service to periodically fetch hosts
# see: https://github.com/StevenBlack/hosts
# adware + malware => 0.0.0.0
readonly update_hosts_script='/etc/coredns/update-hosts.sh'
cat <<EOF >"${update_hosts_script}"
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# we expect to have a static IP but still let's detect this each time
host_name="\$(hostname)"
host_default_ip="\$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')"

# fetch hosts file
hosts_path='${block_hosts_path}'
curl -o "\${hosts_path}" -L https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

# post-process
echo "\${host_default_ip} \${host_name}.local." >>"\${hosts_path}"
EOF
chmod +x "${update_hosts_script}"

cat <<EOF >/etc/systemd/system/update-coredns-hosts.service
[Unit]
Description=Updates CoreDNS hosts file

[Service]
Type=simple
ExecStart=${update_hosts_script}

[Install]
WantedBy=default.target
EOF
cat <<EOF >/etc/systemd/system/update-coredns-hosts.timer
[Unit]
Description=Schedule CoreDNS hosts updates

[Timer]
Persistent=true
OnBootSec=120
OnCalendar=daily

[Install]
WantedBy=timers.target
EOF

# enable services
systemctl daemon-reload
systemctl enable coredns.service
systemctl restart coredns.service
systemctl enable --now update-coredns-hosts.timer
