#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail


# this script installs docker

# see https://docs.docker.com/install/linux/docker-ce/debian/
apt update
apt install -y --no-install-recommends apt-transport-https \
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
