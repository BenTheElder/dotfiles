#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs https://coredns.io/

GO_VERSION="$(curl -s https://go.dev/VERSION?m=text | head -n1)"
echo "Detected current latest go: ${GO_VERSION}"
COREDNS_VERSION='latest'

GOTOOLCHAIN="${GO_VERSION}" \
  GOBIN=/usr/local/bin/ \
  go install -v "github.com/coredns/coredns@${COREDNS_VERSION}"
