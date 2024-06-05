#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs https://coredns.io/

GO_VERSION="$(curl -s https://go.dev/VERSION?m=text | head -n1)"
echo "Detected current latest go: ${GO_VERSION}"
COREDNS_VERSION='latest'

# systemd services don't set $HOME, and go caches etc go under $HOME
# We have bash expand ~ to looking up the homedir and set $HOME
export HOME=~
export GOBIN="${HOME}/go/bin"

GOTOOLCHAIN="${GO_VERSION}" \
  go install -v "github.com/coredns/coredns@${COREDNS_VERSION}"

new_coredns="${GOBIN}/coredns"
old_coredns="$(which coredns)"

# overwrite and restart service if the binary isn't identical
if cmp -s "${new_coredns}" "${old_coredns}"; then
  >&2 echo "New CoreDNS binary is identical, doing nothing"
else
  >&2 echo "New CoreDNS binary is different, copying over and restarting CoreDNS"
  cp "${new_coredns}" "${old_coredns}"
  systemctl restart coredns.service
fi
