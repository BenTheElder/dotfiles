#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this script installs the plex media server
# https://support.plex.tv/articles/235974187-enable-repository-updating-for-supported-linux-server-distributions/

echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
