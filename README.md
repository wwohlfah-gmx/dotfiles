# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
directory is a "package" whose contents mirror `$HOME` — stowing a package
symlinks its files into place.

## Layout

- `zsh/` — `.zshrc` (oh-my-zsh, theme: agnoster)
- `bash/` — `.bashrc`, `.bash_profile`, `.bash_logout`
- `git/` — `.gitconfig`
- `claude/` — `.claude/settings.json` (Claude Code settings)
- `packages/dnf-userinstalled.txt` — explicitly-installed dnf packages (not a
  stow package, just a manifest — see restore steps below)
- `setup.sh` — full machine bootstrap script (dotfiles + shell + editor +
  tools); see below

## Bootstrap a new machine (Fedora)

```sh
git clone https://github.com/wwohlfah-gmx/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` clones and stows this repo, then installs zsh + oh-my-zsh
(agnoster theme, powerline), VS Code, the
[deepseek-harness](https://github.com/deepseek-ai/deepseek-harness) project,
the Claude CLI, and Ollama (pulling `qwen3-coder`). It's safe to re-run —
each step checks whether it already applied (existing clones, existing
oh-my-zsh install, current login shell) before acting again.

### Notes

- **Stow conflicts**: `stow zsh bash git claude` fails if any of
  `~/.zshrc`, `~/.bashrc`, `~/.bash_profile`, `~/.bash_logout`,
  `~/.gitconfig`, or `~/.claude/settings.json` already exist as real files
  (not symlinks) — e.g. on a machine that already has shell config from
  `/etc/skel`. If that happens, move the conflicting file aside first
  (`mv ~/.bashrc ~/.dotfiles-backup/.bashrc`, etc.) and re-run, or use
  `stow --adopt` (see manual restore below) if you want the existing file's
  content pulled into the repo instead.
- **deepseek-harness's web UI** (`pnpm dsh web`) is a foreground server —
  the script only installs and builds it; start it manually when needed.
- **Ollama** only pulls the model; run `ollama run qwen3-coder` yourself to
  start chatting.
- Machine-local secrets (e.g. a GitHub token) are not part of this script
  or the repo — see "Deliberately excluded" below and how `~/.bashrc.d/*` /
  `~/.zshrc.local` (both untracked) are sourced instead.

## Restore just the dotfiles (no other installs)

```sh
sudo dnf install stow git oh-my-zsh-git   # or install oh-my-zsh via its own installer
git clone https://github.com/wwohlfah-gmx/dotfiles.git ~/dotfiles
cd ~/dotfiles

# If any target files already exist for real (not as symlinks), either
# remove them first or use --adopt to pull the existing file's content
# into the repo instead of overwriting it:
#   stow --adopt zsh bash git claude
stow zsh bash git claude

# Reinstall packages that were explicitly installed on the old machine:
sudo dnf install $(cat packages/dnf-userinstalled.txt)
```

To unlink a package: `stow -D <package>`.

## Deliberately excluded

Anything that can hold credentials, tokens, session state, or keys is left
out on purpose, even though some of it lives under `~/.config` or
`~/.local/share`:

- `~/.claude.json`, `~/.claude/.credentials.json`, `~/.claude/sessions`,
  `~/.claude/projects`, `~/.claude/shell-snapshots`
- `~/.ssh`, `~/.gnupg`, `~/.local/share/keyrings`
- `~/.local/share/containers` (registry auth)
- Browser profiles (`~/.mozilla`, `~/.config/mozilla`), `~/.config/evolution`
  (mail account credentials)
- VS Code `globalStorage`/`workspaceStorage` (may hold extension tokens)
- Shell history files (`.zsh_history`, `.bash_history`)

GNOME desktop/theming state (gtk bookmarks, dconf, ibus, fontconfig, etc.)
was also left out as out of scope for a dev/shell config repo — ask if you
want that captured too (likely via `dconf dump` rather than raw files).
