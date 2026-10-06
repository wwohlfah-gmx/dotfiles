#!/usr/bin/env bash
# Claude Code CLI via npm instead of piping the upstream installer (curl|bash)
# to a shell. npm verifies package integrity against the registry; confirmed
# the package exists and node/npm are present on this host (2026-10-06).
#
# npm's default global prefix (/usr/local on this system's Fedora nodejs
# package) is root-owned, so a plain "npm install -g" fails silently-ish with
# EACCES. Point it at a user-writable prefix instead of reaching for sudo.
set -euo pipefail

if [ "$(npm config get prefix)" = "/usr/local" ]; then
  npm config set prefix "$HOME/.local"
fi

npm install -g @anthropic-ai/claude-code
