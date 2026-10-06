#!/usr/bin/env bash
# Bootstrap a new machine: install chezmoi, then let it apply the managed
# dotfiles (home/) and run the provisioning scripts (home/run_once_after_*).
# Safe to re-run: chezmoi only re-applies files that drifted, and
# run_once_ scripts only re-run if their own content changes.
set -euo pipefail

DOTFILES_REPO="https://github.com/wwohlfah-gmx/dotfiles.git"

sudo dnf install -y chezmoi

chezmoi init --apply "$DOTFILES_REPO"

echo "Setup complete."
