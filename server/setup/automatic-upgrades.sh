#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this scipt configures debian to automatically upgrade all the things

# configure options for automatic updates
cat <<EOF >/etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Origins-Pattern {
        // auto-upgrade all the things
        "origin=*";
        "origin=Debian,archive=backports,label=Debian";
}

// cleanup unused dependencies
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Automatically reboot when necessary, even if users are logged in
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
EOF

# configure upgrade interval
cat <<EOF >/etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "always";
APT::Periodic::Download-Upgradeable-Packages "always";
APT::Periodic::AutocleanInterval "always";
APT::Periodic::Unattended-Upgrade "always";
EOF

mkdir -p /etc/systemd/system/apt-daily.timer.d/
cat <<EOF >/etc/systemd/system/apt-daily.timer.d/override.conf
[Timer]
OnCalendar=
OnCalendar=*-*-* *:20:00
RandomizedDelaySec=15m
EOF

systemctl daemon-reload

# upgrade once
unattended-upgrade -d || true
