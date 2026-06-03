# dotfiles

Cross-platform dotfiles managed by [chezmoi](https://chezmoi.io). One command goes from a clean install to a fully configured machine with the right shell, tools, and runtimes.

Supports: Arch/ArchWSL, Ubuntu/Debian, macOS, NixOS, Windows.

---

## Quick start

```sh
# Fresh machine — one command
sh -c "$(curl -fsLS https://raw.githubusercontent.com/Thien-An-Ngo/dotfiles/main/bootstrap.sh)"

# Or directly with chezmoi if already installed
chezmoi init --apply https://github.com/Thien-An-Ngo/dotfiles.git
```

The bootstrap will prompt for: name, email, machine type, WSL, work machine, package categories, and an optional age encryption key.

---

## Repo structure

```
.chezmoi.toml.tmpl     # interactive setup prompts
bootstrap.sh           # curl-able fresh install entry point
home/                  # chezmoi source dir → maps to ~/
  dot_zshrc.tmpl       # zsh config (Oh My Zsh, aliases, PATH, FZF, atuin)
  dot_tmux.conf.tmpl   # tmux (prefix Ctrl+a, pastel powerline theme, TPM)
  dot_gitconfig.tmpl   # git identity + gh credential helper
  dot_zprofile.tmpl    # login shell (pyenv init)
  dot_zshenv           # env for all shells (cargo)
  dot_claude/          # Claude Code settings
  dot_config/          # ~/.config entries (starship, btop, gh, micro, etc.)
  .chezmoiexternal.toml  # auto-cloned repos (OMZ, TPM, nvim, fzf-tab, forgit)
  .chezmoiignore         # chezmoi source exclusions
  run_once_install.sh.tmpl  # runs once on fresh install → dispatches to installer
arch/install.sh        # Arch/ArchWSL package installer (--categories flag)
apt/install.sh         # Debian/Ubuntu installer
brew/install.sh        # macOS Homebrew installer
nix/install.sh         # Nix + home-manager installer
windows/install.ps1    # Windows Scoop installer
windows/Microsoft.PowerShell_profile.ps1  # PowerShell profile
plan/                  # implementation plans and TODO
```

---

## Machine types

| Type | Description |
|------|-------------|
| `archwsl` | Arch Linux inside WSL2 (primary) |
| `arch` | Bare Arch Linux |
| `ubuntu` | Ubuntu/Debian |
| `mac` | macOS |
| `nixos` | NixOS (chezmoi handles dotfiles, NixOS handles packages) |
| `server` | Minimal headless — zsh + starship + tmux + fzf only |

---

## Package categories

| Category | Contents |
|----------|----------|
| `core` | zsh, git, tmux, starship, fzf, neovim, gh, chezmoi |
| `cli` | lsd, bat, ripgrep, fd, btop, delta, hyperfine, tldr, watchexec, topgrade, dua, xh, jq, yq |
| `shell` | zoxide, atuin, navi, thefuck |
| `tui` | yazi, gitui, lazydocker, fastfetch, lazygit |
| `runtimes` | nvm+Node, bun, pyenv, uv, mise, rust/cargo |
| `productivity` | taskwarrior, timewarrior, just, entr |
| `remote` | mosh, tmate |
| `db` | pgcli |
| `utils` | atac, posting, gdu, mani, lychee, kalker, nb, dnote, wl-clipboard, xclip |

Default on fresh install: `core,cli,shell,tui,runtimes`

---

## Auto-cloned by chezmoi

These repos are fetched automatically via `.chezmoiexternal.toml`:

- **Oh My Zsh** → `~/.oh-my-zsh`
- **fzf-tab** → `~/.oh-my-zsh/custom/plugins/fzf-tab`
- **forgit** → `~/.oh-my-zsh/custom/plugins/forgit`
- **TPM** → `~/.tmux/plugins/tpm`
- **Neovim config** → `~/.config/nvim` ([Thien-An-Ngo/nvim](https://github.com/Thien-An-Ngo/nvim))

---

## Shell stack

Loading order: `.zprofile` (login) → `.zshenv` (all shells) → `.zshrc` (interactive)

Runtime managers: Node via nvm/mise, Python via pyenv/mise, Rust via rustup, JS via bun

On `server` profile: OMZ, plugins, atuin, zoxide, navi, thefuck, bun, nvm, and pipx are all skipped.

---

## Tmux

| Setting | Value |
|---------|-------|
| Prefix | `Ctrl+a` |
| Splits | `\|` / `-` |
| Pane nav | `hjkl` |
| Copy mode | vi keys |
| Plugins | resurrect, continuum (auto-restore), yank, vim-tmux-navigator |

On `server` profile: TPM and plugins are skipped.

---

## Machine-local overrides

```sh
cp home/dot_zshrc.local.example ~/.zshrc.local
# edit with API keys, machine-specific PATH, etc.
```

`~/.zshrc.local` is sourced at the end of `.zshrc` and is never committed.

---

## Updating

```sh
chezmoi update   # pulls latest and re-applies
```

---

## Adding a new dotfile

```sh
chezmoi add ~/.config/something
chezmoi cd        # opens source dir in $SHELL
git add . && git commit -m "..."
git push
```

---

## NixOS note

chezmoi owns dotfiles (`~/.zshrc`, `~/.config/starship.toml`, etc.). NixOS/home-manager owns packages and services. Do not manage chezmoi-tracked files via home-manager.
