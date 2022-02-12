#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

hosts_path="${BLOCK_HOSTS_PATH:?}"

# regex hostname patterns to allowlist
host_allowlist_patterns=(
    # https://github.com/StevenBlack/hosts/issues/1887
    # TODO: this was removed from the upstream source,
    # but does not yet appear in StevenBlack/hosts
    # When that is fixed, remove this.
    'oneapi\.telematicsct\.com'
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

# filter it
grep_args=(-vE)
for pat in "${host_allowlist_patterns[@]}"; do
    grep_args+=(-e '^0\.0\.0\.0 '"$pat")
done
grep "${grep_args[@]}" "${raw_hosts_path}" >"${hosts_path}"

# add entry for this server
echo "${host_default_ip} ${host_name}.${my_public_tld_suffix}." >>"${hosts_path}"

