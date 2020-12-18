#!/bin/bash

args=(
# get best audio
-f bestaudio
--audio-quality 0
# just get audio
--extract-audio
# mp3 is a reasonable format from many sources
--audio-format mp3
)

set -x;
youtube-dl "${args[@]}" "$@"