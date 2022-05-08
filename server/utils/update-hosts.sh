#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

hosts_path="${BLOCK_HOSTS_PATH:?}"

# regex hostname patterns to allowlist
host_allowlist_patterns=(
    # allow google shopping results
    # breaking these annoys users on the network
    '(www\.)?googleadservices.com'
    'clickserve.dartsearch.net'
    'ad.doubleclick.net'
)

# this is really annoying
# surely there should be a reserved domain for this!
my_public_tld_suffix='home.elder.dev'

# we expect to have a static IP but still let's detect this each time
host_name="$(hostname)"
host_default_ip="$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')"

# fetch hosts file
raw_hosts_path="${hosts_path}.raw"
curl -o "${raw_hosts_path}" -L https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts

# filter it if we have any allowlist patterns
if [ ${#host_allowlist_patterns[@]} -eq 0 ]; then
    cp "${raw_hosts_path}" "${hosts_path}"
else
    grep_args=(-vE)
    for pat in "${host_allowlist_patterns[@]}"; do
        grep_args+=(-e '^0\.0\.0\.0 '"$pat"'$')
    done
    grep "${grep_args[@]}" "${raw_hosts_path}" >"${hosts_path}"
fi

# add entry for this server
echo "${host_default_ip} ${host_name}.${my_public_tld_suffix}." >>"${hosts_path}"

