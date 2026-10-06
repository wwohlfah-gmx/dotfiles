#!/usr/bin/env bash
# Catppuccin GTK theme + Ptyxis terminal palette + Nerd Font. Not part of the
# curl|sh hardening pass (install.py is executed via `python3`, not piped to
# a shell, and the font download is a pinned-version data archive, not code)
# -- unchanged from the previous setup.sh, just relocated into chezmoi.
set -euo pipefail

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

# Ptyxis terminal color palette (file is chezmoi-managed:
# dot_local/share/org.gnome.Ptyxis/palettes/catppuccin.palette); select it on
# the default profile.
PTYXIS_UUID=$(gsettings get org.gnome.Ptyxis default-profile-uuid | tr -d "'")
gsettings set "org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${PTYXIS_UUID}/" palette catppuccin

# MesloLGS Nerd Font: not packaged in Fedora repos. Starship's Catppuccin
# preset (dot_config/starship.toml) uses Nerd Font icon glyphs beyond what the
# `powerline-fonts` package covers, so Ptyxis needs a real Nerd Font or those
# icons render as tofu boxes.
NERD_FONT_VER="v3.5.1"
if [ ! -d ~/.local/share/fonts/MesloNerdFont ]; then
  curl -fsSL -o /tmp/Meslo.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VER}/Meslo.zip"
  mkdir -p ~/.local/share/fonts/MesloNerdFont
  unzip -o -q /tmp/Meslo.zip -d ~/.local/share/fonts/MesloNerdFont
  fc-cache -f ~/.local/share/fonts
fi
