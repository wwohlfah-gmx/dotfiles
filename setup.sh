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
stow zsh bash git claude vscode ptyxis eza
cd ~

#################
# zsh + oh-my-zsh
#################
sudo dnf install -y zsh eza fzf

if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

#################
# starship prompt (Catppuccin Powerline preset)
#################
if [ ! -x ~/.local/bin/starship ]; then
  sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y -b ~/.local/bin
fi
# Preset (~/.config/starship.toml) and zsh wiring (ZSH_THEME="",
# `eval "$(starship init zsh)"`) are handled by the stowed `zsh` package.

#################
# install vscode
#################
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update || true
sudo dnf install -y code
code --install-extension Catppuccin.catppuccin-vsc
# Active theme (workbench.colorTheme) is set in the stowed `vscode` package.

#################
# Catppuccin GTK theme + Ptyxis terminal palette
#################
GTK_FLAVOR="macchiato"
GTK_ACCENT="mauve"
GTK_VER="v1.0.3"
GTK_THEME_NAME="catppuccin-${GTK_FLAVOR}-${GTK_ACCENT}-standard+default"

if [ ! -d ~/.local/share/themes/"$GTK_THEME_NAME" ]; then
  curl -LsSo /tmp/catppuccin-gtk-install.py "https://raw.githubusercontent.com/catppuccin/gtk/${GTK_VER}/install.py"
  # Fedora's Python (3.14+) rejects type= combined with
  # argparse.BooleanOptionalAction; this script predates that change.
  sed -i '/type=bool,/d' /tmp/catppuccin-gtk-install.py
  python3 /tmp/catppuccin-gtk-install.py "$GTK_FLAVOR" "$GTK_ACCENT"
fi

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.wm.preferences theme "$GTK_THEME_NAME"

# libadwaita (GTK4) support: v1.0.3's own --link flag points at a
# "-dark"-suffixed directory that doesn't match this release's actual
# extracted folder name, so link manually against the real path instead.
mkdir -p ~/.config/gtk-4.0
for f in assets gtk.css gtk-dark.css; do
  ln -sf ~/.local/share/themes/"$GTK_THEME_NAME"/gtk-4.0/"$f" ~/.config/gtk-4.0/"$f"
done

# Ptyxis terminal color palette (file installed via the stowed `ptyxis`
# package); select it on the default profile.
PTYXIS_UUID=$(gsettings get org.gnome.Ptyxis default-profile-uuid | tr -d "'")
gsettings set "org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${PTYXIS_UUID}/" palette catppuccin

# MesloLGS Nerd Font: not packaged in Fedora repos. Starship's Catppuccin
# preset (see zsh/.config/starship.toml) uses Nerd Font icon glyphs beyond
# what the `powerline-fonts` package covers, so Ptyxis needs a real Nerd
# Font or those icons render as tofu boxes.
NERD_FONT_VER="v3.5.1"
if [ ! -d ~/.local/share/fonts/MesloNerdFont ]; then
  curl -fsSL -o /tmp/Meslo.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VER}/Meslo.zip"
  mkdir -p ~/.local/share/fonts/MesloNerdFont
  unzip -o -q /tmp/Meslo.zip -d ~/.local/share/fonts/MesloNerdFont
  fc-cache -f ~/.local/share/fonts
fi

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
