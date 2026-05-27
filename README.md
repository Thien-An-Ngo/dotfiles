# dotfiles

Personal system configuration for a **WSL2 Ubuntu** environment. This repository lives at `~/.config` and is the single source of truth for the shell, terminal, editor, and CLI tool setup.

---

## Repository structure

```
~/.config/
├── home/               # dotfiles that live in ~ (symlinked by install.sh)
│   ├── .zshrc          # main shell config (Oh My Zsh, aliases, PATH, FZF)
│   ├── .zshenv         # env vars for all shell types (pyenv, pipx, cargo)
│   ├── .zprofile       # login-shell env (pyenv init --path)
│   ├── .tmux.conf      # tmux config with pastel powerline theme
│   └── .gitconfig      # global git identity + gh credential helper
├── claude/
│   └── settings.json   # Claude Code global settings (plugins, hooks, theme)
├── btop/               # btop system monitor config
├── gh/                 # GitHub CLI (config.yml — hosts.yml is gitignored)
├── git/                # global gitignore
├── micro/              # micro editor keybindings + settings
├── neofetch/           # neofetch display config
├── pypoetry/           # Poetry: virtualenvs.in-project = true
├── systemd/user/       # user systemd services (OpenClaw gateway)
├── thefuck/            # thefuck settings
├── starship.toml       # Starship prompt (pastel powerline palette)
├── install.sh          # symlink setup script
├── CLAUDE.md           # guidance for Claude Code sessions
└── README.md           # this file
```

> **Neovim** lives in `nvim/` as a **git submodule** pointing to [`Thien-An-Ngo/nvim`](https://github.com/Thien-An-Ngo/nvim). See `nvim/CLAUDE.md` for full documentation. To update the pinned commit: `git submodule update --remote nvim` from `~/.config`.

---

## Quick start (new machine)

```bash
# 1. Clone into ~/.config (--recurse-submodules pulls nvim too)
git clone --recurse-submodules <your-remote-url> ~/.config

# 2. Run the install script
cd ~/.config
bash install.sh

# 3. Reload shell
source ~/.zshrc

# 4. Inside tmux — install plugins
# Press:  Prefix + I
```

`install.sh` is idempotent: existing files are moved to `~/.dotfiles-backup-<timestamp>/` before symlinking.

---

## Environment-specific settings

Secrets and machine-local values go in `~/.zshrc.local` (gitignored, sourced at the end of `.zshrc`). A template is provided:

```bash
cp ~/.config/home/.zshrc.local.example ~/.zshrc.local
# then edit ~/.zshrc.local with real values
```

| Variable | Notes |
|---|---|
| `GEMINI_API_KEY` | Google Gemini API key |
| `ANTHROPIC_API_KEY` | Claude / Anthropic API key |
| `OPENAI_API_KEY` | OpenAI API key |
| nvm node version | Run `nvm install --lts` on first boot |

---

## Tools covered

### Shell

| Tool | Purpose | Install |
|---|---|---|
| [Zsh](https://www.zsh.org/) | Shell | `sudo apt install zsh && chsh -s $(which zsh)` |
| [Oh My Zsh](https://ohmyz.sh/) | Zsh framework | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` |
| [Starship](https://starship.rs/) | Cross-shell prompt | `curl -sS https://starship.rs/install.sh \| sh` |
| [FZF](https://github.com/junegunn/fzf) | Fuzzy finder | `sudo apt install fzf` or `git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install` |
| [Zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` | `curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \| sh` |
| [thefuck](https://github.com/nvbn/thefuck) | Command corrector | `pip install thefuck --user` (installed into `~/.thefuck-env` here) |

### Terminal multiplexer

| Tool | Purpose | Install |
|---|---|---|
| [Tmux](https://github.com/tmux/tmux) | Terminal multiplexer | `sudo apt install tmux` |
| [TPM](https://github.com/tmux-plugins/tpm) | Tmux plugin manager | `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm` |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions | via TPM (`Prefix + I`) |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save sessions | via TPM |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | Better clipboard | via TPM |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless vim/tmux nav | via TPM |

Tmux prefix is **`Ctrl+a`** (German keyboard-friendly). Plugins install with `Prefix + I`.

### Editors

| Tool | Purpose | Install |
|---|---|---|
| [Neovim](https://neovim.io/) | Primary editor (LazyVim) | `sudo apt install neovim` or download from releases |
| [Micro](https://micro-editor.github.io/) | Lightweight terminal editor | `sudo apt install micro` |
| [Nano](https://www.nano-editor.org/) | Basic editor | `sudo apt install nano` |

### Modern CLI replacements

These are aliased over their POSIX counterparts in `.zshrc`:

| Replacement | Original | Install |
|---|---|---|
| [lsd](https://github.com/lsd-rs/lsd) | `ls` | `cargo install lsd` or `sudo apt install lsd` |
| [bat](https://github.com/sharkdp/bat) | `cat` | `sudo apt install bat` (binary may be `batcat`) |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` | `sudo apt install ripgrep` |
| [fd](https://github.com/sharkdp/fd) | `find` | `sudo apt install fd-find` (binary is `fdfind`, symlink to `fd`) |
| [btop](https://github.com/aristocratos/btop) | `top` | `sudo apt install btop` |
| [dust](https://github.com/bootandy/dust) | `du` | `cargo install du-dust` |
| [procs](https://github.com/dalance/procs) | `ps` | `cargo install procs` |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | neofetch | `sudo add-apt-repository ppa:zhangsongcui3371/fastfetch && sudo apt install fastfetch` |

### Development runtimes & package managers

| Tool | Purpose | Install |
|---|---|---|
| [nvm](https://github.com/nvm-sh/nvm) | Node version manager | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh \| bash` |
| [pyenv](https://github.com/pyenv/pyenv) | Python version manager | `curl https://pyenv.run \| bash` |
| [Rustup](https://rustup.rs/) | Rust toolchain | `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh` |
| [Bun](https://bun.sh/) | JavaScript runtime & toolkit | `curl -fsSL https://bun.sh/install \| bash` |
| [Poetry](https://python-poetry.org/) | Python packaging | `curl -sSL https://install.python-poetry.org \| python3 -` |
| [Encore](https://encore.dev/) | Backend framework CLI | `curl -L https://encore.dev/install.sh \| bash` |
| [Lando](https://lando.dev/) | Local dev environments (Docker-based) | Download `.deb` from [releases](https://github.com/lando/lando/releases) |

### Version control & GitHub

| Tool | Purpose | Install |
|---|---|---|
| [Git](https://git-scm.com/) | Version control | `sudo apt install git` |
| [GitHub CLI](https://cli.github.com/) | GitHub from the terminal | `sudo apt install gh` or see [install docs](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) |
| [Lazygit](https://github.com/jesseduffield/lazygit) | Terminal UI for git | `sudo apt install lazygit` or download from releases |

### AI & coding assistants

| Tool | Purpose | Install |
|---|---|---|
| [Claude Code](https://claude.ai/code) | Anthropic's coding CLI | `npm install -g @anthropic-ai/claude-code` |

Claude Code settings (plugins, hooks, theme) are tracked at `claude/settings.json` and symlinked to `~/.claude/settings.json`.

### Other services

| Tool | Purpose | Notes |
|---|---|---|
| [OpenClaw](https://openclaw.ai/) | API gateway | Runs as a systemd user service; unit file tracked in `systemd/user/` |
| [wslu](https://wslutiliti.es/wslu/) | WSL utilities | `sudo apt install wslu` |
| [Lando](https://lando.dev/) | Docker-based dev envs | `~/.lando/bin` is on PATH |

---

## WSL clipboard

```bash
pbcopy   # → clip.exe   (copy to Windows clipboard)
pbpaste  # → powershell.exe Get-Clipboard
fclip <file>  # pipe file contents to clipboard
```

---

## Adding a new config

1. Add the file under the appropriate directory in this repo (or `home/` if it lives in `~`)
2. Add a `link` call for it in `install.sh`
3. Update `.gitignore` if there are generated/sensitive sibling files to exclude
4. Update this README

---

## Updating an existing machine

```bash
cd ~/.config
git pull
bash install.sh   # re-links anything new, skips existing correct links
source ~/.zshrc
```
