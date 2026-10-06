# dotfiles

Managed with [chezmoi](https://www.chezmoi.io/). `home/` is the source state;
`chezmoi apply` renders it onto `$HOME`, overwriting pre-existing files safely
(it converges `$HOME` to match the tracked state, after showing a diff — no
symlink conflicts, nothing to move aside first on a fresh account).

## Layout

- `.chezmoiroot` — points chezmoi at `home/` as the managed subtree; `README.md`,
  `packages/`, and `setup.sh` sit outside it and are never touched by `chezmoi apply`.
- `home/dot_zshrc`, `home/dot_config/starship.toml` — oh-my-zsh, prompt: Starship
  w/ Catppuccin Macchiato Powerline preset
- `home/dot_bashrc`, `dot_bash_profile`, `dot_bash_logout`
- `home/dot_gitconfig`
- `home/dot_claude/settings.json` — Claude Code settings + the dotfiles-sync
  reminder hooks
- `home/dot_config/Code/User/settings.json` — VS Code theme: Catppuccin Macchiato
- `home/dot_config/eza/theme.yml`, `home/dot_config/tmux/tmux.conf`,
  `home/dot_config/bat/config`
- `home/dot_local/share/org.gnome.Ptyxis/palettes/catppuccin.palette` (Latte for
  light mode, Macchiato for dark)
- `home/run_once_after_*.sh` — provisioning scripts chezmoi runs once each
  (oh-my-zsh, starship, VS Code, GTK/Ptyxis/Nerd Font theming, tmux plugin,
  deepseek-harness, Claude CLI, Ollama); re-run automatically if their own
  content changes
- `packages/dnf-userinstalled.txt` — explicitly-installed dnf packages (plain
  manifest, outside the chezmoi-managed subtree — see restore steps below)
- `setup.sh` — installs chezmoi, then `chezmoi init --apply`

## Bootstrap a new machine (Fedora)

```sh
git clone https://github.com/wwohlfah-gmx/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` installs `chezmoi` (packaged in Fedora's repos) and runs
`chezmoi init --apply`, which clones this repo as chezmoi's source state,
lays down every file under `home/`, and then runs each `run_once_after_*.sh`
script once: zsh + oh-my-zsh with a Starship prompt, VS Code (+ Catppuccin
extension), the Catppuccin GTK theme (macchiato/mauve, with libadwaita
support) and Ptyxis terminal palette, a Nerd Font,
[deepseek-harness](https://github.com/deepseek-ai/deepseek-harness), the
Claude CLI, and Ollama (pulling `qwen3-coder`). It's safe to re-run — chezmoi
only reapplies files that drifted, and each `run_once_` script only re-runs
if its own content changes.

### Notes

- **No more stow-style conflicts.** A pre-existing `.bashrc`/`.zshrc` (e.g.
  from `/etc/skel` on a fresh account) is simply overwritten by `chezmoi
  apply` after showing you the diff — nothing to move aside, no `--adopt`
  equivalent, no manual retry.
- **Pinned installers instead of `curl|sh`.** oh-my-zsh and starship aren't
  installed via their upstream install scripts piped to a shell; oh-my-zsh is
  cloned at a pinned commit, starship is downloaded as a release tarball with
  its sha256 checked against GitHub's own reported digest. Ollama is a Fedora
  package (`dnf install ollama`), and the Claude CLI installs via `npm`
  instead of its curl installer. Check each `run_once_after_*.sh` header
  comment for the pinned version/commit and re-verify before bumping it.
- **GTK theme installer**: downloads catppuccin/gtk's official `install.py`
  (v1.0.3) and patches out a `type=bool` argparse call that Python 3.14+
  rejects (Fedora ships 3.14; the upstream script predates that argparse
  change). It also symlinks `~/.config/gtk-4.0/*` manually instead of using
  the script's own `--link` flag, because that release's `--link` points at a
  `-dark`-suffixed theme directory that doesn't match what the release zip
  actually extracts to.
- **deepseek-harness's web UI** (`pnpm dsh web`) is a foreground server —
  the script only installs and builds it; start it manually when needed.
- **Ollama** only pulls the model; run `ollama run qwen3-coder` yourself to
  start chatting.
- Machine-local secrets (e.g. a GitHub token) are not part of this repo —
  see "Deliberately excluded" below and how `~/.bashrc.d/*` /
  `~/.zshrc.local` (both untracked) are sourced instead.

## Restore just the dotfiles (no other installs)

```sh
sudo dnf install chezmoi
chezmoi init --apply https://github.com/wwohlfah-gmx/dotfiles.git

# Reinstall packages that were explicitly installed on the old machine:
sudo dnf install $(cat ~/.local/share/chezmoi/packages/dnf-userinstalled.txt)
```

This still runs every `run_once_after_*.sh` script (oh-my-zsh, starship,
VS Code, etc.) — use `chezmoi init` (without `--apply`) then
`chezmoi diff`/`chezmoi apply <specific target>` if you only want some of the
managed files without the provisioning scripts.

To remove chezmoi's management of a file: `chezmoi forget <path>`.

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

The GTK/libadwaita theme itself (Catppuccin, downloaded from its GitHub
release by `run_once_after_40-gtk-theme.sh`) and its `gsettings` selection are
*not* stored as files in this repo — they're reproduced by re-running that
script, same as the dnf package manifest. Other GNOME desktop/theming state
(gtk bookmarks, dconf, ibus, fontconfig, etc.) is still left out as out of
scope for a dev/shell config repo — ask if you want more of that captured too
(likely via `dconf dump` rather than raw files).
