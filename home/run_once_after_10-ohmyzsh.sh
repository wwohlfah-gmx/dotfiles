#!/usr/bin/env bash
# oh-my-zsh framework, pinned to a specific commit instead of piping the
# upstream installer (curl|sh) to a shell. oh-my-zsh doesn't tag releases,
# so a commit SHA is the closest thing to a pinned version; re-verify and
# bump it occasionally (check: https://github.com/ohmyzsh/ohmyzsh/commits/master).
set -euo pipefail

OMZ_COMMIT="60c9a7a839b790cd905d0fd4419435124fd1bdc0"  # master, as of 2026-10-06

sudo dnf install -y zsh eza fzf ripgrep bat fd-find

if [ ! -d ~/.oh-my-zsh ]; then
  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  git -C ~/.oh-my-zsh checkout --detach "$OMZ_COMMIT"
fi

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi
