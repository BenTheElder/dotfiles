#!/bin/bash

ARGS=(
# Uniform Format
# Grab the best MP4 if one exists, best available if not.
--format 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best'
# prefer ffmpeg for any media conversion
--prefer-ffmpeg

# final file is an MKV container
--merge-output-format mkv

# Get All Subs to SRT
--write-sub
--all-subs
--convert-subs srt

# Get metadata
--add-metadata
#--write-description
#--write-thumbnail
#--write-annotations
#--write-info-json
)

set -x;
youtube-dl "${ARGS[@]}" "$@"