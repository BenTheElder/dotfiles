#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# this scipt disables sleeping
# https://wiki.debian.org/Suspend#Disable_suspend_and_hibernation
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
