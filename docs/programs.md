# Programs by Category

All tools installed by the dotfiles bootstrap, grouped by install category.

---

## Core

| Tool | Description | Alias |
|------|-------------|-------|
| [zsh](https://www.zsh.org/) | Z shell — primary interactive shell | — |
| [git](https://git-scm.com/) | Version control | `g` |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer | `ta`, `tn`, `tl`, `tk` |
| [starship](https://starship.rs/) | Cross-shell prompt | — |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for the terminal | — |
| [neovim](https://neovim.io/) | Hyperextensible Vim-based editor | — |
| [gh](https://cli.github.com/) | GitHub CLI | — |
| [chezmoi](https://chezmoi.io/) | Dotfiles manager | — |
| base-devel / build-essential | Compiler toolchain (gcc, make, etc.) | — |

---

## CLI

| Tool | Description | Alias |
|------|-------------|-------|
| [lsd](https://github.com/lsd-rs/lsd) | Modern `ls` with icons and colors | `ls`, `ll`, `lt` |
| [bat](https://github.com/sharkdp/bat) | `cat` clone with syntax highlighting and git integration | `cat` |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast recursive grep | `grep` |
| [fd](https://github.com/sharkdp/fd) | Simple, fast alternative to `find` | `find` |
| [btop](https://github.com/aristocratos/btop) | Resource monitor with a TUI interface | `top` (fallback) |
| [bottom](https://github.com/ClementTsang/bottom) (`btm`) | Cross-platform system monitor with graphs | `top` |
| [dust](https://github.com/bootandy/dust) | Intuitive `du` — disk usage by directory | `du` (fallback) |
| [dua](https://github.com/Byron/dua-cli) | Interactive disk usage analyzer | `du` |
| [procs](https://github.com/dalance/procs) | Modern `ps` replacement | `ps` |
| [git-delta](https://github.com/dandavison/delta) | Syntax-highlighting pager for git diffs | — |
| [hyperfine](https://github.com/sharkdp/hyperfine) | Command-line benchmarking tool | `bench` |
| [tealdeer](https://github.com/dbrgn/tealdeer) | Fast `tldr` client — simplified man pages | `help` |
| [watchexec](https://github.com/watchexec/watchexec) | Runs a command when files change | `watch` |
| [topgrade](https://github.com/topgrade-rs/topgrade) | Upgrades all package managers at once | `upgrade` |
| [xh](https://github.com/ducaale/xh) | Friendly HTTP client (HTTPie-compatible) | `http` |
| [skim](https://github.com/lotabout/skim) (`sk`) | Fuzzy finder written in Rust | — |
| [jq](https://jqlang.github.io/jq/) | JSON processor | `jq` (with `--tab`) |
| [yq](https://github.com/mikefarah/yq) | YAML/JSON/TOML processor | — |
| [fx](https://github.com/antonmedv/fx) | Interactive JSON viewer and processor | — |

---

## Shell

| Tool | Description | Alias |
|------|-------------|-------|
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` that learns your habits | `cd` |
| [atuin](https://github.com/atuinsh/atuin) | Shell history sync and search with SQLite backend | — |
| [navi](https://github.com/denisidoro/navi) | Interactive cheatsheet tool with `Ctrl+G` widget | — |
| [thefuck](https://github.com/nvbn/thefuck) | Corrects the previous console command | `fuck` |

---

## TUI

| Tool | Description | Alias |
|------|-------------|-------|
| [yazi](https://github.com/sxyazi/yazi) | Blazing-fast terminal file manager | `y` |
| [gitui](https://github.com/extrawurst/gitui) | Fast terminal UI for git | `gu` |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | TUI for Docker container management | — |
| [macchina](https://github.com/Macchina-CLI/macchina) | System info fetcher (like neofetch, but faster) | `sysinfo` |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | Fast system info display | `ff` |
| [lazygit](https://github.com/jesseduffield/lazygit) | Simple TUI for git commands | — |

---

## Runtimes

| Tool | Description | Alias |
|------|-------------|-------|
| [rust / cargo](https://www.rust-lang.org/) | Rust toolchain and package manager | — |
| [nvm](https://github.com/nvm-sh/nvm) + Node LTS | Node version manager + Node.js | — |
| [bun](https://bun.sh/) | Fast JavaScript runtime, bundler, and package manager | — |
| [pyenv](https://github.com/pyenv/pyenv) | Python version manager | — |
| [uv](https://github.com/astral-sh/uv) | Extremely fast Python package manager | `pip`, `pipx` |
| [pipx](https://pipx.pypa.io/) | Install Python CLI tools in isolated environments | — |
| [mise](https://mise.jdx.dev/) | Polyglot runtime version manager (replaces nvm/pyenv) | — |

---

## Productivity

| Tool | Description | Alias |
|------|-------------|-------|
| [taskwarrior](https://taskwarrior.org/) (`task`) | Command-line task manager | — |
| [timewarrior](https://timewarrior.net/) (`timew`) | Time tracking from the command line | — |
| [just](https://github.com/casey/just) | Command runner — a better `make` for project scripts | — |
| [entr](https://eradman.com/entrproject/) | Run commands when files change | — |
| [pet](https://github.com/knqyf263/pet) | CLI snippet manager | — |

---

## Remote

| Tool | Description | Alias |
|------|-------------|-------|
| [mosh](https://mosh.org/) | Mobile shell — persistent SSH over flaky connections | — |
| [tmate](https://tmate.io/) | Instant terminal sharing via SSH | — |

---

## Database

| Tool | Description | Alias |
|------|-------------|-------|
| [pgcli](https://www.pgcli.com/) | PostgreSQL CLI with autocompletion and syntax highlighting | — |

---

## Utils

| Tool | Description | Alias |
|------|-------------|-------|
| [wl-clipboard](https://github.com/bugaevc/wl-clipboard) (`wl-copy`/`wl-paste`) | Wayland clipboard utilities | `pbcopy`, `pbpaste` |
| [xclip](https://github.com/astrand/xclip) | X11 clipboard utility | `pbcopy`, `pbpaste` |
| [atac](https://github.com/Julien-cpsn/ATAC) | Terminal API client (Postman-like TUI) | — |
| [posting](https://github.com/darrenburns/posting) | Modern TUI HTTP client | — |
| [gdu](https://github.com/dundee/gdu) | Fast disk usage analyzer with TUI | — |
| [mani](https://github.com/alajmo/mani) | CLI tool to manage multiple repositories | — |
| [lychee](https://github.com/lycheeverse/lychee) | Fast link checker | — |
| [kalker](https://github.com/PaddiM8/kalker) | Feature-rich terminal calculator with math syntax | — |
| [nb](https://github.com/xwmx/nb) | CLI note-taking, bookmarking, and archiving | — |
| [dnote](https://github.com/dnote/dnote) | Simple command-line notebook | — |

---

## Auto-cloned by chezmoi

These repos are fetched automatically via `home/.chezmoiexternal.toml` on first apply:

| Repo | Destination | Purpose |
|------|-------------|---------|
| [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) | `~/.oh-my-zsh` | Zsh framework |
| [Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab) | `~/.oh-my-zsh/custom/plugins/fzf-tab` | fzf completion menu |
| [wfxr/forgit](https://github.com/wfxr/forgit) | `~/.oh-my-zsh/custom/plugins/forgit` | fzf git wrappers |
| [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) | `~/.tmux/plugins/tpm` | Tmux plugin manager |
| [Thien-An-Ngo/nvim](https://github.com/Thien-An-Ngo/nvim) | `~/.config/nvim` | Neovim config |
