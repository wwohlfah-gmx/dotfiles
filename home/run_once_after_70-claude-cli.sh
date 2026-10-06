#!/usr/bin/env bash
# Claude Code CLI via npm instead of piping the upstream installer (curl|bash)
# to a shell. npm verifies package integrity against the registry; confirmed
# the package exists and node/npm are present on this host (2026-10-06).
set -euo pipefail

npm install -g @anthropic-ai/claude-code
