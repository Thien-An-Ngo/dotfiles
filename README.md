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

### Shell history

| Tool | Purpose | Install |
|---|---|---|
| [atuin](https://atuin.sh/) | Magic shell history — searchable, syncable, with stats; replaces `Ctrl+R` | `cargo install atuin` or `curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh \| sh` |

Initialised at the bottom of `.zshrc` via `eval "$(atuin init zsh)"`. Login with `atuin login` to enable cross-machine sync.

### Shell completion

| Tool | Purpose | Install |
|---|---|---|
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replace zsh tab-completion menu with fzf | `git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab` |

Listed in `plugins=(... fzf-tab)` in `.zshrc`. `install.sh` clones it automatically.

### Productivity & task management

| Tool | Purpose | Install |
|---|---|---|
| [Taskwarrior](https://taskwarrior.org/) | Feature-rich CLI task manager (`task`) | `sudo apt install taskwarrior` |
| [Timewarrior](https://timewarrior.net/) | Time tracking linked to Taskwarrior (`timew`) | `sudo apt install timewarrior` |
| [tock](https://github.com/jraf/tock) | Minimal time-tracking CLI | `cargo install tock` |
| [just](https://github.com/casey/just) | Command runner — like `make` without the footguns | `cargo install just` |
| [entr](https://eradman.com/entrproject/) | Re-run commands when files change | `sudo apt install entr` |
| [pet](https://github.com/knqyf263/pet) | CLI snippet manager with fzf search | Download binary from [releases](https://github.com/knqyf263/pet/releases) |
| [await](https://github.com/slavaGanzin/await) | Wait in parallel for commands/URLs to become ready | `npm install -g await-cli` |
| [Cronboard](https://cronboard.io/) | Cron job monitoring and alerting service | Web service + CLI companion |

### Docker & containers

| Tool | Purpose | Install |
|---|---|---|
| [depot](https://depot.dev/) | Remote Docker image builder — faster builds via persistent remote cache and native arm64/amd64 hardware | `curl -L https://depot.dev/install.sh \| sh` |
| [ctop](https://github.com/bcicen/ctop) | `top`-like metrics for containers | `sudo apt install ctop` or download binary |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | Terminal UI for Docker — lazygit equivalent | `curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh \| bash` |

### HTTP client

| Tool | Purpose | Install |
|---|---|---|
| [xh](https://github.com/ducaale/xh) | Fast HTTP client — friendly `curl`/`httpie` replacement | `cargo install xh` |

Aliased as `http` in `.zshrc`.

### File manager

| Tool | Purpose | Install |
|---|---|---|
| [yazi](https://yazi-rs.github.io/) | Blazing-fast terminal file manager with image preview | `cargo install yazi-fm yazi-cli` |
| [ya](https://yazi-rs.github.io/docs/cli) | `yazi` companion CLI — plugins, flavours, themes | installed with yazi |

Aliased as `y` in `.zshrc`. Also available inside Neovim via `<leader>fy`.

### System info

| Tool | Purpose | Install |
|---|---|---|
| [macchina](https://github.com/Macchina-CLI/macchina) | Fast system info display — neofetch alternative | `cargo install macchina` |

Aliased as `sysinfo` in `.zshrc`.

### Remote & terminal sharing

| Tool | Purpose | Install |
|---|---|---|
| [mosh](https://mosh.org/) | Mobile shell — roaming SSH replacement, handles packet loss | `sudo apt install mosh` |
| [tmate](https://tmate.io/) | Instant terminal sharing (pair programming, support) | `sudo apt install tmate` |
| [gotty](https://github.com/sorenisanerd/gotty) | Share terminal as a web app | Download binary from [releases](https://github.com/sorenisanerd/gotty/releases) |
| [xxh](https://github.com/xxh/xxh) | Bring your shell and dotfiles to any SSH host | `pip install xxh-xxh` |

### Database

| Tool | Purpose | Install |
|---|---|---|
| [pgcli](https://www.pgcli.com/) | PostgreSQL CLI with autocomplete and syntax highlighting | `pipx install pgcli` |

### Environment & secrets

| Tool | Purpose | Install |
|---|---|---|
| [envio](https://envio-cli.io/) | Encrypted environment profile manager | `cargo install envio` or see [install docs](https://github.com/humblepenguinn/envio) |

### Notes & writing

| Tool | Purpose | Install |
|---|---|---|
| [obsidian-cli](https://github.com/Yakitrak/obsidian-cli) | Open/search your Obsidian vault from the terminal (`obs`) | `brew install yakitrak/yakitrak/obsidian-cli` or download binary |
| [prosaic](https://github.com/nathanielksmith/prosaic) | Cut-up prose generation tool | `pip install prosaic` |
| [hygg](https://github.com/ronaldsuwandi/hygg) | Distraction-free terminal reading experience | Download binary from releases |

### Calendar

| Tool | Purpose | Install |
|---|---|---|
| [khal](https://lostpackets.de/khal/) | CLI calendar — reads/writes CalDAV (iCal compatible) | `pipx install khal` |
| [calcurse](https://calcurse.org/) | TUI calendar and todo app, offline | `sudo apt install calcurse` |

### Cooking

| Tool | Purpose | Install |
|---|---|---|
| [CookCLI](https://cooklang.org/) | Parse and manage recipes in the `.cook` format | Download from [cooklang.org/cli](https://cooklang.org/cli/global-install/) |

### Utilities

| Tool | Purpose | Install |
|---|---|---|
| [tldr](https://tldr.sh/) | Simplified community man pages; aliased as `help` | `npm install -g tldr` or `cargo install tealdeer` |
| [has](https://github.com/kdabir/has) | Check if a tool is installed and its version | `curl -sL https://git.io/_has \| bash -s -- --install` |
| [yank](https://github.com/mptre/yank) | Select terminal output and copy to clipboard | `sudo apt install yank` |
| [clipboard](https://github.com/Slackadays/Clipboard) | Cut/copy/paste anything from the terminal (`cb`) | `curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh \| sh` |
| [bcal](https://github.com/jarun/bcal) | Byte and base calculator / unit converter | `sudo apt install bcal` |
| [mklicense](https://github.com/cezaraugusto/mklicense) | Generate LICENSE files interactively | `npm install -g mklicense` |
| [add-gitignore](https://github.com/TejasQ/add-gitignore) | Add `.gitignore` templates interactively | `npm install -g add-gitignore` |
| [mynav](https://github.com/Bugswriter/mynav) | Terminal directory bookmark navigator | Clone and follow README |
| [google-font-installer](https://github.com/lordgiotto/google-font-installer) | Install Google Fonts from the terminal | `npm install -g google-font-installer` |

### Theming

| Tool | Purpose | Install |
|---|---|---|
| [themer](https://themer.dev/) | Generate consistent themes across editors, terminals, and wallpapers from a palette | `npm install -g themer` |

### Note-taking & knowledge

| Tool | Purpose | Install |
|---|---|---|
| [nb](https://xwmx.github.io/nb/) | Full-featured CLI notes, bookmarks, archiving and knowledge base with encryption and sync | `bash <(curl -sS https://xwmx.github.io/nb/bin/install)` |
| [dnote](https://www.getdnote.com/) | Simple command-line notebook with optional cloud sync | `curl -sf https://dnote.io/scripts/install_linux.sh \| sh` |
| [taskbook](https://github.com/klaussinani/taskbook) | Tasks, notes, and boards in your terminal — npm global | `npm install -g taskbook` |
| [eureka](https://github.com/simeg/eureka) | Capture and store ideas without leaving the terminal | `cargo install eureka` |
| [notesmd-cli](https://github.com/nicholasgasior/notesmd-cli) | Markdown-based notes from the CLI | see project README |
| [octotype](https://github.com/nicholasgasior/octotype) | GitHub-themed typing practice in the terminal | see project README |

### Interactive cheatsheets & command search

| Tool | Purpose | Install |
|---|---|---|
| [navi](https://github.com/denisidoro/navi) | Interactive cheatsheet tool — `Ctrl+G` opens a fuzzy-searchable command picker with argument placeholders | `cargo install navi` |
| [intelli-shell](https://github.com/lasantosr/intelli-shell) | Bookmark shell commands with placeholders; fuzzy-search your own library | `cargo install intelli-shell` |
| [pet](https://github.com/knqyf263/pet) | Lightweight CLI snippet manager with fzf search | download binary from [releases](https://github.com/knqyf263/pet/releases) |

`navi` is wired into zsh via `eval "$(navi widget zsh)"` — `Ctrl+G` in any prompt. `forgit` is an OMZ plugin (added to `plugins=`) that wraps common `git` commands with fzf.

### Modern `ls` alternatives

| Tool | Purpose | Install |
|---|---|---|
| [eza](https://github.com/eza-community/eza) | `ls` replacement with icons, git status, tree view — spiritual successor to `exa` | `cargo install eza` |
| [lsd](https://github.com/lsd-rs/lsd) | `ls` replacement — currently aliased as `ls` | `cargo install lsd` |

### Disk usage

| Tool | Purpose | Install |
|---|---|---|
| [gdu](https://github.com/dundee/gdu) | Fast TUI disk usage analyser — navigate directories and delete | download binary or `go install github.com/dundee/gdu/v5/cmd/gdu@latest` |
| [dust](https://github.com/bootandy/dust) | `du` replacement — currently aliased as `du` | `cargo install du-dust` |

### API clients

| Tool | Purpose | Install |
|---|---|---|
| [posting](https://github.com/darrenburns/posting) | Modern TUI API client — Postman/Insomnia in the terminal | `pipx install posting` |
| [atac](https://github.com/Julien-cpsn/ATAC) | Atomically Tested API Client — full REST/GraphQL TUI client | `cargo install atac` |
| [xh](https://github.com/ducaale/xh) | Fast HTTP client — aliased as `http` | `cargo install xh` |
| [jwt-ui](https://github.com/jwt-rs/jwt-ui) | TUI for decoding, verifying, and generating JWT tokens | `cargo install jwt-ui` |

### Git tools

| Tool | Purpose | Install |
|---|---|---|
| [forgit](https://github.com/wfxr/forgit) | Interactive fzf wrappers for `git add`, `log`, `diff`, `checkout`, etc. | auto-cloned to OMZ plugins by `install.sh` |
| [lazygit](https://github.com/jesseduffield/lazygit) | Full TUI for git | already listed above |
| [mani](https://github.com/nicholasgasior/mani) | Run commands across multiple repos simultaneously | download binary from [releases](https://github.com/nicholasgasior/mani/releases) |

### Networking & web

| Tool | Purpose | Install |
|---|---|---|
| [lychee](https://lychee.cli.rs/) | Fast link checker — finds dead links in code, markdown, HTML | `cargo install lychee` |
| [cariddi](https://github.com/edoardottt/cariddi) | Web crawler to discover endpoints, parameters, and secrets | `go install github.com/edoardottt/cariddi/cmd/cariddi@latest` |
| [dirsearch](https://github.com/maurosoria/dirsearch) | Web path/directory brute-force tool | `pipx install dirsearch` |
| [netwatch](https://github.com/nicholasgasior/netwatch) | Real-time network traffic monitoring | see project README |
| [whosthere](https://github.com/nicholasgasior/whosthere) | Show who is currently connected to your network | see project README |
| [quien](https://github.com/nicholasgasior/quien) | Identify who/what is on your local network | see project README |

### Remote access & file sharing

| Tool | Purpose | Install |
|---|---|---|
| [mosh](https://mosh.org/) | Mobile shell — roaming SSH that handles packet loss | `sudo apt install mosh` |
| [tmate](https://tmate.io/) | Instant terminal sharing | `sudo apt install tmate` |
| [gotty](https://github.com/sorenisanerd/gotty) | Share terminal as a web app (browser-accessible) | download binary from [releases](https://github.com/sorenisanerd/gotty/releases) |
| [xxh](https://github.com/xxh/xxh) | Bring your shell and plugins to any SSH host without installing | `pip install xxh-xxh` |
| [lazyssh](https://github.com/stephanharbort/lazyssh) | TUI SSH connection manager | download binary from [releases](https://github.com/stephanharbort/lazyssh/releases) |
| [jocalsend](https://github.com/nicholasgasior/jocalsend) | LocalSend TUI — cross-platform LAN file sharing | see project README |

### Finance

| Tool | Purpose | Install |
|---|---|---|
| [bagels](https://github.com/EnricoBTG/Bagels) | Terminal expense tracker and budgeting | `pipx install bagels` |
| [moneyterm](https://github.com/nicholasgasior/moneyterm) | Terminal budgeting and money management | see project README |

### Backup

| Tool | Purpose | Install |
|---|---|---|
| [gobackup](https://gobackup.github.io/) | Automated database and file backup (MySQL, PostgreSQL, S3, etc.) | `curl -sSL https://gobackup.github.io/install \| bash` |

### Systemd

| Tool | Purpose | Install |
|---|---|---|
| [isd](https://github.com/isd-project/isd) | Interactive TUI for browsing, starting, stopping, and inspecting systemd units | `pipx install isd-project` |

### Calculator & math

| Tool | Purpose | Install |
|---|---|---|
| [kalker](https://github.com/PaddiM8/kalker) | Calculator with full math syntax, variables, functions, and unit conversions | `cargo install kalker` |
| [bcal](https://github.com/jarun/bcal) | Byte and base conversion calculator | `sudo apt install bcal` |

### CSV & data

| Tool | Purpose | Install |
|---|---|---|
| [xan](https://github.com/medialab/xan) | Fast CSV toolkit — slice, filter, aggregate, join (like awk/miller for CSV) | `cargo install xan` |

### Publishing

| Tool | Purpose | Install |
|---|---|---|
| [surge](https://surge.sh/) | Zero-config static site publishing from any directory | `npm install -g surge` |

### Terminal multiplexer

| Tool | Purpose | Install |
|---|---|---|
| [cy](https://cyd.brane.dev/) | Terminal multiplexer with session recording and time-travel replay | download from [releases](https://github.com/cfoust/cy/releases) |
| [tmux](https://github.com/tmux/tmux) | Primary multiplexer — config tracked in `home/.tmux.conf` | already listed above |

### References & bibliography

| Tool | Purpose | Install |
|---|---|---|
| [bibiman](https://github.com/s-r-o/bibiman) | TUI manager for BibTeX reference files | see project README |

### Miscellaneous TUI tools

| Tool | Purpose | Install |
|---|---|---|
| [andcli](https://github.com/nicholasgasior/andcli) | Android device management from the terminal | see project README |
| [basalt](https://github.com/bash-oo/basalt) | Package manager for bash/shell scripts | see project README |
| [bitchat-tui](https://github.com/jackdoe/bitchat-tui) | Peer-to-peer encrypted terminal messaging client | see project README |
| [cdv](https://github.com/nicholasgasior/cdv) | `cd` with live directory preview | see project README |
| [cliamp](https://github.com/nicholasgasior/cliamp) | Terminal music player | see project README |
| [daylight](https://github.com/nicholasgasior/daylight) | Circadian colour-temperature tool for the terminal | see project README |
| [dealve-tui](https://github.com/nicholasgasior/dealve-tui) | TUI frontend for the Delve Go debugger | see project README |
| [deletor](https://github.com/nicholasgasior/deletor) | Safer file deletion — sends to trash instead of `rm` permanently | see project README |
| [dotstate](https://github.com/nicholasgasior/dotstate) | Audits the state of dotfile symlinks across a machine | see project README |
| [endcord](https://github.com/nicholasgasior/endcord) | Discord TUI client | see project README |
| [gloomberb](https://github.com/nicholasgasior/gloomberb) | — | see project README |
| [godap](https://github.com/nicholasgasior/godap) | Go Debug Adapter Protocol client | see project README |
| [hyprmoncfg](https://github.com/nicholasgasior/hyprmoncfg) | TUI for configuring Hyprland monitor layouts | see project README |
| [lue](https://github.com/nicholasgasior/lue) | — | see project README |
| [podliner](https://github.com/nicholasgasior/podliner) | Terminal podcast player and manager | see project README |
| [qu](https://github.com/nicholasgasior/qu) | — | see project README |
| [spiel](https://github.com/nicholasgasior/spiel) | Terminal slideshow / presentation tool | see project README |
| [tuios](https://github.com/nicholasgasior/tuios) | — | see project README |

---

## Faster alternatives & performance upgrades

### Shell startup (currently ~3.9 s — fixable)

The two biggest culprits are `nvm` and `pyenv` loading eagerly on every shell start.

#### Option A — drop-in lazy fix (no tool change)

Add this to `.zshrc` in place of the nvm block to lazy-load it only when `node`/`nvm` is first called:

```zsh
# lazy nvm — loads only on first use
export NVM_DIR="$HOME/.nvm"
nvm() { unset -f nvm node npm npx; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm "$@" }
node() { unset -f nvm node npm npx; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; node "$@" }
npm()  { unset -f nvm node npm npx; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; npm  "$@" }
npx()  { unset -f nvm node npm npx; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; npx  "$@" }
```

#### Option B — replace nvm + pyenv entirely with `mise`

| Tool | Replaces | Install |
|---|---|---|
| [mise](https://mise.jdx.dev/) | `nvm` + `pyenv` + `rustup` + any other version manager — one Rust binary, lazy-loads, 10× faster startup | `curl https://mise.run \| sh` |

`mise` is a drop-in polyglot version manager. After installing:
```bash
mise use --global node@lts python@3.12
# then remove the nvm and pyenv blocks from .zshrc / .zprofile
eval "$(mise activate zsh)"   # add this instead
```

---

### Python packaging — replace pip/pipx with `uv`

| Tool | Replaces | Speedup | Install |
|---|---|---|---|
| [uv](https://github.com/astral-sh/uv) | `pip`, `pip3`, `pipx`, `virtualenv`, `pip-tools` | 10–100× | `cargo install uv` or `curl -LsSf https://astral.sh/uv/install.sh \| sh` |

`uv` is a Rust-based drop-in replacement. Alias `pip='uv pip'` in `.zshrc` and use `uv tool install` instead of `pipx install`.

---

### Git diff — add `delta` as pager

| Tool | Replaces | Install |
|---|---|---|
| [delta](https://github.com/dandavison/delta) | Default `git diff` pager — adds syntax highlighting, side-by-side view, line numbers, merge conflict style | `cargo install git-delta` |

After installing, wire it into git globally:
```bash
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.side-by-side true
```

Or add to `home/.gitconfig` under `[core]` / `[delta]`.

---

### Tool-for-tool upgrade table

| Current | Faster alternative | Why | Install |
|---|---|---|---|
| `tldr` (npm) | [tealdeer](https://github.com/dbrgn/tealdeer) (`tldr`) | Rust binary — instant startup vs. Node cold-start; auto-updates cache | `cargo install tealdeer` |
| `entr` | [watchexec](https://github.com/watchexec/watchexec) | Recursive by default, smarter signal handling, ignores `.git`/`node_modules` automatically | `cargo install watchexec-cli` |
| `lazygit` | [gitui](https://github.com/extrawurst/gitui) | Rust — noticeably faster on large repos with many files | `cargo install gitui` |
| `btop` | [bottom](https://github.com/ClementTsang/bottom) (`btm`) | Lower resource usage; Rust; more customisable widget layout | `cargo install bottom` |
| `dust` / `gdu` | [dua-cli](https://github.com/Byron/dua-cli) (`dua`) | Parallel disk scan — fastest of all three; interactive delete mode | `cargo install dua-cli` |
| `fzf` | [skim](https://github.com/lotabout/skim) (`sk`) | Rust fzf — near-identical interface, marginally faster on huge input | `cargo install skim` |
| `docker build` | [depot](https://depot.dev/) | Remote persistent cache + native multi-arch hardware; typical 2–10× build speedup | `curl -L https://depot.dev/install.sh \| sh` |

---

### Missing essentials worth adding

| Tool | Purpose | Install |
|---|---|---|
| [jq](https://stedolan.github.io/jq/) | JSON processor — pipe any JSON through `jq .` | `sudo apt install jq` |
| [yq](https://github.com/mikefarah/yq) | YAML / JSON / TOML / XML processor (same syntax as jq) | `sudo apt install yq` or `go install github.com/mikefarah/yq/v4@latest` |
| [fx](https://github.com/antonmedv/fx) | Interactive JSON viewer and processor in the terminal | `npm install -g fx` |
| [hyperfine](https://github.com/sharkdp/hyperfine) | Benchmark any shell command with statistical analysis — aliased as `bench` | `cargo install hyperfine` |
| [topgrade](https://github.com/topgrade-rs/topgrade) | Upgrade every package manager at once (apt, cargo, npm, pip, bun, OMZ, etc.) — aliased as `upgrade` | `cargo install topgrade` |
| [delta](https://github.com/dandavison/delta) | Git diff pager with syntax highlighting — wired into `home/.gitconfig` | `cargo install git-delta` |
| [mise](https://mise.jdx.dev/) | Polyglot version manager replacing nvm + pyenv — activates automatically if installed | `curl https://mise.run \| sh` |
| [uv](https://github.com/astral-sh/uv) | Rust Python package manager — aliased as `pip` and `pipx` when present | `cargo install uv` |
| [gitui](https://github.com/extrawurst/gitui) | Rust git TUI — aliased as `gu` | `cargo install gitui` |
| [bottom](https://github.com/ClementTsang/bottom) (`btm`) | System monitor — aliased as `top` when present, falls back to btop | `cargo install bottom` |
| [dua-cli](https://github.com/Byron/dua-cli) (`dua`) | Fast interactive disk analyser — aliased as `du` when present, falls back to dust | `cargo install dua-cli` |
| [watchexec](https://github.com/watchexec/watchexec) | File watcher — aliased as `watch` | `cargo install watchexec-cli` |

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
