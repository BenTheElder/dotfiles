#!/usr/bin/env bash
# sets up shared agent instructions (AGENTS.md) and skills from the private
# BenTheElder/agent-config repo for Claude Code, Copilot (VS Code),
# Antigravity and Gemini CLI, by symlinking it into each tool's global config
#
# Usage: utils/setup_agent_config.sh
#
# safe to re-run, existing non-empty files are moved to <path>.bak.<timestamp>
#
# - Claude Code reads ~/.claude/rules/*.md and ~/.claude/skills/<name>
# - Copilot in VS Code reads the same paths by default (chat.instructionsFilesLocations
#   and chat.agentSkillsLocations include ~/.claude/rules and ~/.claude/skills)
# - Antigravity loads ~/.gemini/config/plugins/<name> (the repo is laid out as a plugin)
# - Gemini CLI reads ~/.gemini/GEMINI.md

set -o errexit -o nounset -o pipefail

AGENT_CONFIG_REPO="${AGENT_CONFIG_REPO:-BenTheElder/agent-config}"
AGENT_CONFIG_DIR="${AGENT_CONFIG_DIR:-${HOME}/agent-config}"

# clone the private repo if we don't have it yet
# NOTE: this may need a security key touch, github SSH is used even for https URLs
ensure_repo() {
  if [ -d "${AGENT_CONFIG_DIR}/.git" ]; then
    return
  fi
  if command -v gh >/dev/null; then
    gh repo clone "${AGENT_CONFIG_REPO}" "${AGENT_CONFIG_DIR}"
  else
    git clone "git@github.com:${AGENT_CONFIG_REPO}.git" "${AGENT_CONFIG_DIR}"
  fi
}

# link_path <target> <link>
# symlinks link -> target, replacing existing symlinks and empty files
# anything else is moved aside first so we never lose data
link_path() {
  local target="$1" link="$2"
  mkdir -p "$(dirname "${link}")"
  if [ -e "${link}" ] && [ ! -L "${link}" ] && { [ -d "${link}" ] || [ -s "${link}" ]; }; then
    local backup
    backup="${link}.bak.$(date +%Y%m%d%H%M%S)"
    echo "Moving existing ${link} to ${backup}"
    mv "${link}" "${backup}"
  fi
  (set -x; ln -sfn "${target}" "${link}")
}

# links each skill and removes links to skills that were deleted from the repo
link_skills() {
  local skills_dir="$1" repo_skills="${AGENT_CONFIG_DIR}/skills"
  mkdir -p "${skills_dir}"
  for skill in "${repo_skills}"/*/; do
    skill="${skill%/}"
    link_path "${skill}" "${skills_dir}/$(basename "${skill}")"
  done
  for link in "${skills_dir}"/*; do
    if [ -L "${link}" ] && [ ! -e "${link}" ]; then
      case "$(readlink "${link}")" in
        "${repo_skills}"/*) (set -x; rm "${link}") ;;
      esac
    fi
  done
}

# antigravity doesn't discover a symlinked plugin directory, so we make a real
# one and link its contents instead
link_antigravity_plugin() {
  local plugin_dir="${HOME}/.gemini/config/plugins/agent-config"
  if [ -L "${plugin_dir}" ]; then
    (set -x; rm "${plugin_dir}")
  fi
  mkdir -p "${plugin_dir}"
  for f in plugin.json rules skills; do
    link_path "${AGENT_CONFIG_DIR}/${f}" "${plugin_dir}/${f}"
  done
}

main() {
  ensure_repo
  # Claude Code + Copilot
  link_path "${AGENT_CONFIG_DIR}/AGENTS.md" "${HOME}/.claude/rules/agents.md"
  link_skills "${HOME}/.claude/skills"
  # Antigravity
  link_antigravity_plugin
  # Gemini CLI
  link_path "${AGENT_CONFIG_DIR}/AGENTS.md" "${HOME}/.gemini/GEMINI.md"
}

main "$@"
