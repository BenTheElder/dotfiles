#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this scipt installs https://coredns.io/

version='1.8.7'

arch='amd64'
base_url="https://github.com/coredns/coredns/releases/download/v${version}"
tarball="coredns_${version}_linux_${arch}.tgz"
tarball_url="${base_url}/${tarball}"

# create tempdir to perform downloads in
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

# download tarball and hash
curl -o "${tmpdir}/${tarball}" -L "${tarball_url}"
curl -o "${tmpdir}/${tarball}.sha256" -L "${tarball_url}.sha256"

cat "${tmpdir}/${tarball}.sha256"

# check hash
sha256sum --check --status "${tmpdir}/${tarball}.sha256"

# extract and install
tar -C /usr/local/bin -xzvf "${tmpdir}/${tarball}"
