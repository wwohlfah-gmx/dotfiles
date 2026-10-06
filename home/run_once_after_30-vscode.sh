#!/usr/bin/env bash
# VS Code via Microsoft's signed repo (gpgcheck=1) -- already not curl|sh,
# unchanged from the previous setup.sh, just relocated into chezmoi.
set -euo pipefail

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update || true
sudo dnf install -y code
code --install-extension Catppuccin.catppuccin-vsc
code --install-extension anthropic.claude-code
# Active theme (workbench.colorTheme) is chezmoi-managed (dot_config/Code/User/settings.json).
# The Claude Code extension shells out to the `claude` CLI installed later (run_once_after_80).
