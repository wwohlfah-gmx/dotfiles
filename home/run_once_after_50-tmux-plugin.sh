#!/usr/bin/env bash
# tmux + Catppuccin theme. Already pinned to a tag (not curl|sh) in the
# previous setup.sh, just relocated into chezmoi.
set -euo pipefail

sudo dnf install -y tmux

# Installed manually (not via TPM) per upstream docs -- TPM has plugin
# name-conflict issues. Config is chezmoi-managed (dot_config/tmux/tmux.conf).
TMUX_CATPPUCCIN_VER="v2.3.0"
if [ ! -d ~/.config/tmux/plugins/catppuccin/tmux ]; then
  mkdir -p ~/.config/tmux/plugins/catppuccin
  git clone -q -b "$TMUX_CATPPUCCIN_VER" https://github.com/catppuccin/tmux.git \
    ~/.config/tmux/plugins/catppuccin/tmux
fi
