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

## Restore on a new machine (Fedora)

```sh
sudo dnf install stow git oh-my-zsh-git   # or install oh-my-zsh via its own installer
git clone <this-repo-url> ~/dotfiles
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
