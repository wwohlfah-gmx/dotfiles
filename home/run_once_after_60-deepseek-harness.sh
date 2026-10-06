#!/usr/bin/env bash
# deepseek-harness. Unchanged from the previous setup.sh (clones at the
# default branch HEAD, not pinned) -- out of scope for this migration's
# curl|sh hardening pass, just relocated into chezmoi.
set -euo pipefail

if [ ! -d ~/lab/deepseek-harness/.git ]; then
  git clone https://github.com/deepseek-ai/deepseek-harness.git ~/lab/deepseek-harness
fi
cd ~/lab/deepseek-harness
pnpm install
pnpm run build
# Run the web UI manually when wanted -- it's a foreground server:
#   cd ~/lab/deepseek-harness && pnpm dsh web
