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
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

cat <<EOF >/etc/systemd/system/apt-daily.timer.d/override.conf
[Timer]
OnCalendar=
OnCalendar=*-*-* 0,4,8,12,16,20:00
RandomizedDelaySec=15m
EOF

cat <<EOF >/etc/systemd/system/apt-daily.timer.d/override.conf
[Timer]
OnCalendar=
OnCalendar=*-*-* 0,4,8,12,16,20:20
RandomizedDelaySec=1m
EOF

systemctl daemon-reload

# upgrade once
unattended-upgrade -d
