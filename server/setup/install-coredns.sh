#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this scipt installs https://coredns.io/

# TODO: automatic updates
version='1.11.1'
# TODO: detect arch, have per-arch hashes?
arch='amd64'
base_url="https://github.com/coredns/coredns/releases/download/v${version}"
tarball="coredns_${version}_linux_${arch}.tgz"
tarball_url="${base_url}/${tarball}"
# trust on first use, manually obtain this when selecting
# new versions, then pin it.
# curl -L "${tarball_url}.sha256"
# curl -L "https://github.com/coredns/coredns/releases/download/v${version}/coredns_${version}_linux_amd64.tgz.sha256"
hash='f96cdee0934c5c12a28bb0fb080bed688fdd7bfdeae2f64984f02bdec2d65498  coredns_'"${version}"'_linux_amd64.tgz'

if which coredns >/dev/null; then
    current_version="$(coredns --version | head -n1 | sed -nr 's#CoreDNS-(.*)#\1#p')"
    if [[ "${current_version}" = "${version}" ]]; then
        >&2 echo "CoreDNS v${version} already installed"
        exit 0
    fi
fi

>&2 echo "Installing CoreDNS v${version}"


# create tempdir to perform downloads in
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

# download tarball and check hash
curl -o "${tmpdir}/${tarball}" -L "${tarball_url}"
echo "${hash}" >"${tmpdir}/${tarball}.sha256"

# check hash
(cd "${tmpdir}" && sha256sum --check --status "${tmpdir}/${tarball}.sha256")

# extract and install
tar -C /usr/local/bin -xzvf "${tmpdir}/${tarball}"
