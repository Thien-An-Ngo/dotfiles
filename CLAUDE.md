# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A dotfiles/configuration repository tracking `~/.config` on a WSL2 (Ubuntu) machine. It is the single source of truth for shell, terminal, editor, and CLI tool config — not application source code.

`install.sh` creates symlinks from `~` (and `~/.claude/`) into this repo so the repo files are the live files.

## Structure at a glance

```
home/           ← dotfiles that live in ~ (symlinked by install.sh)
claude/         ← ~/.claude/settings.json
btop/           ← btop system monitor
gh/             ← GitHub CLI (config.yml; hosts.yml is gitignored)
git/            ← global gitignore
micro/          ← micro editor bindings + settings
neofetch/       ← neofetch display config
pypoetry/       ← Poetry config (virtualenvs.in-project = true)
systemd/user/   ← user systemd services (OpenClaw gateway)
thefuck/        ← thefuck settings
starship.toml   ← Starship prompt (pastel powerline palette)
install.sh      ← idempotent symlink setup; run after cloning
```

> Neovim lives in `nvim/` (its own git repo with its own `CLAUDE.md`).

## Key files

| File | Purpose |
|------|---------|
| `home/.zshrc` | Shell config: Oh My Zsh, plugins (git, pyenv), aliases, PATH, FZF, zoxide, starship init |
| `home/.zshenv` | Env for all shells: pyenv root, pipx PATH, cargo env |
| `home/.zprofile` | Login-shell env: `pyenv init --path` |
| `home/.tmux.conf` | Tmux: prefix `Ctrl+a`, pastel powerline theme, vi copy mode, TPM plugins |
| `home/.gitconfig` | Git identity + `gh` credential helper |
| `starship.toml` | Prompt segments, pastel-powerline color palette |
| `claude/settings.json` | Claude Code: enabled plugins, PreCompact hook, theme |

## Shell stack

Loading order: `.zprofile` (login) → `.zshenv` (all shells) → `.zshrc` (interactive).

**CLI tool aliases** (conditional on binary presence): `ls→lsd`, `cat→bat`, `grep→rg`, `find→fd`, `top→btop`, `du→dust`, `ps→procs`.

**PATH resolution order** (first wins):
`~/.lando/bin` → `~/.thefuck-env/bin` → `~/.bun/bin` → `~/.cargo/bin` → `~/.encore/bin` → `~/.local/bin` → `~/.pyenv/bin` → `/opt/nvim[-linux-x86_64]/bin` → `/opt/mssql-tools18/bin` → Cursor

**Runtime managers:** Node via `nvm`, Python via `pyenv`, Rust via `rustup`, JS/TS via `bun`.

## Tmux

Prefix: `Ctrl+a` | Splits: `|` / `-` | Pane nav: `hjkl` | Copy: vi keys, yank to `clip.exe` | Reload: `Prefix + r`

Plugins (TPM): tmux-resurrect, tmux-continuum (auto-restore), tmux-yank, vim-tmux-navigator.

## Applying changes

After editing `home/.zshrc` or `home/.zshenv` (which are already the live files via symlinks):
```sh
source ~/.zshrc
```

After editing `home/.tmux.conf`:
```sh
tmux source-file ~/.tmux.conf   # or Prefix + r inside tmux
```

After editing `claude/settings.json`: changes apply to next Claude Code session automatically.

## Gitignore rationale

Excluded: `google-chrome/`, `Code/` (VSCode), `crush/`/`goose/` (agent skill symlinks), `gh/hosts.yml` (auth tokens), `nvim/` (own repo), `pypoetry/poetry.lock` + `pyproject.toml` (project-specific), `micro/backups/` + `buffers/`.
