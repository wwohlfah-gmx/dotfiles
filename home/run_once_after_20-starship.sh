#!/usr/bin/env bash
# starship prompt binary. Not packaged in Fedora (dnf info starship: no match,
# checked 2026-10-06). Downloads a pinned release tarball and verifies its
# sha256 instead of piping the upstream installer (curl|sh) to a shell.
# Re-verify and bump the version + digest from a release's own page before
# updating: https://github.com/starship/starship/releases
set -euo pipefail

STARSHIP_VERSION="v1.26.0"
STARSHIP_SHA256="321f0dd7af8340a5f2e6a8fec6538a04f617486f9ec70d878f91c09cd8deef22"
STARSHIP_ASSET="starship-x86_64-unknown-linux-gnu.tar.gz"
STARSHIP_URL="https://github.com/starship/starship/releases/download/${STARSHIP_VERSION}/${STARSHIP_ASSET}"

if [ ! -x ~/.local/bin/starship ]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  curl -fsSL -o "$TMP/$STARSHIP_ASSET" "$STARSHIP_URL"
  echo "${STARSHIP_SHA256}  $TMP/$STARSHIP_ASSET" | sha256sum -c -
  mkdir -p ~/.local/bin
  tar -xzf "$TMP/$STARSHIP_ASSET" -C "$TMP"
  install -m 0755 "$TMP/starship" ~/.local/bin/starship
fi
# Preset (~/.config/starship.toml) and zsh wiring (ZSH_THEME="",
# `eval "$(starship init zsh)"`) are chezmoi-managed (dot_zshrc, dot_config/starship.toml).
