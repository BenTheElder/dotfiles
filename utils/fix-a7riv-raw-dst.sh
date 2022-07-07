#!/usr/bin/env bash
set -o errexit nounset pipefail -x

# run this to offset $PWD/*.ARW from not-DST to DST
# TODO: probably will need this in reverse someday ...

offset_time='=-07:00'
date_time_correction='+=0:0:0 1:0:0'

exiftool \
    -DateTimeOriginal"${date_time_correction:?}" \
    -CreateDate"${date_time_correction:?}" \
    -IFD0:ModifyDate"${date_time_correction:?}" \
    -IFD1:ModifyDate"${date_time_correction:?}" \
    -SonyDateTime"${date_time_correction:?}" \
    -OffsetTime"${offset_time:?}" \
    -OffsetTimeOriginal"${offset_time:?}" \
    -OffsetTimeDigitized"${offset_time:?}" \
    *.ARW