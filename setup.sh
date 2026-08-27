#!/usr/bin/env bash
set -euo pipefail

###
# setup environment
###

# folder layout:
# ~/env      - contains all software to make this environment great
# ~/lab      - contains all projects
# ~/dotfiles - contains all dotfiles; symlinked into place with GNU Stow

cd ~
mkdir -p env lab dotfiles

#################
# stow + dotfiles
#################
sudo dnf install -y stow

DOTFILES_REPO="https://github.com/wwohlfah-gmx/dotfiles.git"
if [ ! -d ~/dotfiles/.git ]; then
  git clone "$DOTFILES_REPO" ~/dotfiles
fi
# https://medium.com/quick-programming/managing-dotfiles-with-gnu-stow-9b04c155ebad

cd ~/dotfiles
stow zsh bash git claude
cd ~

#################
# zsh + oh-my-zsh + powerline theme
#################
sudo dnf install -y zsh powerline powerline-fonts strfile eza fzf vim-powerline tmux-powerline
# https://fedoramagazine.org/add-power-terminal-powerline/

if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

# Theme, plugins, and the powerline-daemon shell hook all live in the
# stowed ~/.zshrc (ZSH_THEME=agnoster, plugins=(...)) -- nothing to set here.

#################
# install vscode
#################
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update || true
sudo dnf install -y code

#################
# deepseek harness
#################
if [ ! -d ~/lab/deepseek-harness/.git ]; then
  git clone https://github.com/deepseek-ai/deepseek-harness.git ~/lab/deepseek-harness
fi
cd ~/lab/deepseek-harness
pnpm install
pnpm run build
cd ~
# Run the web UI manually when wanted -- it's a foreground server:
#   cd ~/lab/deepseek-harness && pnpm dsh web

#################
# claude cli install
#################
curl -fsSL https://claude.ai/install.sh | bash

#################
# ollama
#################
curl -fsSL https://ollama.com/install.sh | sh
ollama pull qwen3-coder
# Start chatting manually with: ollama run qwen3-coder

echo "Setup complete."
