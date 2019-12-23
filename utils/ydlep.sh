#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

set -x;
# zero pad season / episode
SEASON="$(printf '%02d' "${SEASON:?}")"
EPISODE="$(printf '%02d' "${EPISODE:?}")"
TITLE="${TITLE:+" - ${TITLE}"}"
BASEDIR="${BASEDIR:-"/mnt/storage/plex/tv"}"

# call ydl.sh with download location based on $SHOW, $SEASON, $EPISODE
"${SCRIPT_DIR}/ydl.sh" "--output=${BASEDIR}/${SHOW:?}/Season ${SEASON:?}/${SHOW:?} - s${SEASON:?}e${EPISODE:?}${TITLE}.%(ext)s" "$@"
