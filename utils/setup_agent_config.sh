#!/usr/bin/env bash
# clones the private BenTheElder/agent-config repo (shared AGENTS.md, skills and
# workflows) if needed, and runs its setup.sh to link it into each agent tool
#
# Usage: utils/setup_agent_config.sh

set -o errexit -o nounset -o pipefail

AGENT_CONFIG_REPO="${AGENT_CONFIG_REPO:-BenTheElder/agent-config}"
AGENT_CONFIG_DIR="${AGENT_CONFIG_DIR:-${HOME}/agent-config}"

# NOTE: this may need a security key touch, github SSH is used even for https URLs
if [ ! -d "${AGENT_CONFIG_DIR}/.git" ]; then
  if command -v gh >/dev/null; then
    gh repo clone "${AGENT_CONFIG_REPO}" "${AGENT_CONFIG_DIR}"
  else
    git clone "git@github.com:${AGENT_CONFIG_REPO}.git" "${AGENT_CONFIG_DIR}"
  fi
fi

exec "${AGENT_CONFIG_DIR}/setup.sh"
