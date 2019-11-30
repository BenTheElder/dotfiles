#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this scipt bootstraps my typical debian server setup

# disable sleeping
disable_sleep() {
  systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
}

# installs some common packages
install_basic_packages() {
  apt update
  apt install -y --no-reccommends git
}

configure_unattended_updates() {
# configure options for automatic updates
cat <<EOF >/etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Origins-Pattern {
        // auto-upgrade all the things
        "origin=*"
}

// cleanup unused dependencies
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Automatically reboot when necessary, even if users are logged in
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-WithUsers "true";
EOF
# configure upgrade interval
cat <<EOF >/etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
}

# installs docker
install_docker() {
  # see https://docs.docker.com/install/linux/docker-ce/debian/
  apt update
  apt install -y --no-reccommends apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/debian \
    $(lsb_release -cs) \
    stable"
  apt update
  apt-get install docker-ce docker-ce-cli containerd.io
}

main() {
  set -x;
  disable_sleep
  install_basic_packages
  configure_unattended_updates
  # upgrade once
  unattended-upgrade -d
}

main
