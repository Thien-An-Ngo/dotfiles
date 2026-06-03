#!/usr/bin/env bash
# brew-install.sh — install every tool used by this dotfiles repo via Homebrew
# Works on macOS (Apple Silicon & Intel) and Linux (Linuxbrew).
# Idempotent: skips anything already installed.

set -euo pipefail

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

has() { command -v "$1" &>/dev/null; }

IS_MAC=false
[[ "$(uname -s)" == "Darwin" ]] && IS_MAC=true

# ─── Ensure Homebrew is installed ────────────────────────────────────────────
if ! has brew; then
    echo ""
    echo "── Installing Homebrew ──"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for this session (location differs by platform/arch)
    if $IS_MAC; then
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"   # Apple Silicon
        else
            eval "$(/usr/local/bin/brew shellenv)"      # Intel
        fi
    else
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    green "  Homebrew installed"
fi

brew update

# ─── Helper: brew install if binary not present ──────────────────────────────
brw() {
    local formula="$1"
    local bin="${2:-$1}"
    if has "$bin"; then
        info "already installed: $bin"
    else
        echo "  [brew] $formula"
        brew install "$formula"
    fi
}

# ─── Helper: brew install --cask (macOS only) ────────────────────────────────
cask() {
    if ! $IS_MAC; then
        info "skipping cask (Linux): $1"
        return
    fi
    local cask_name="$1"
    local bin="${2:-$1}"
    if has "$bin"; then
        info "already installed: $bin"
    else
        echo "  [cask] $cask_name"
        brew install --cask "$cask_name"
    fi
}

# ─── Core shell & build tools ────────────────────────────────────────────────
echo ""
echo "── Core shell & build tools ──"
brw zsh
brw git
brw curl
brw wget
brw unzip
$IS_MAC || brw gcc make  # Linux only; macOS ships clang via Xcode CLT

# ─── Oh My Zsh ───────────────────────────────────────────────────────────────
echo ""
echo "── Oh My Zsh ──"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    green "  oh-my-zsh installed"
else
    info "already installed: oh-my-zsh"
fi

# ─── Zsh default shell ───────────────────────────────────────────────────────
echo ""
echo "── Default shell ──"
ZSH_PATH="$(brew --prefix)/bin/zsh"
if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi
if [ "$SHELL" != "$ZSH_PATH" ]; then
    chsh -s "$ZSH_PATH"
    green "  default shell set to zsh (re-login to take effect)"
else
    info "already default: zsh"
fi

# ─── Terminal multiplexer ────────────────────────────────────────────────────
echo ""
echo "── Tmux ──"
brw tmux

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    green "  TPM installed (run Prefix+I inside tmux to install plugins)"
else
    info "already installed: tpm"
fi

# ─── Prompt & shell enhancements ─────────────────────────────────────────────
echo ""
echo "── Prompt & shell enhancements ──"
brw starship
brw fzf
brw zoxide
brw atuin

# fzf-tab (Oh My Zsh plugin)
FZF_TAB_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
    green "  fzf-tab installed"
else
    info "already installed: fzf-tab"
fi

# forgit (Oh My Zsh plugin)
FORGIT_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/forgit"
if [ ! -d "$FORGIT_DIR" ]; then
    git clone https://github.com/wfxr/forgit "$FORGIT_DIR"
    green "  forgit installed"
else
    info "already installed: forgit"
fi

# ─── Editor ──────────────────────────────────────────────────────────────────
echo ""
echo "── Neovim ──"
brw neovim nvim

# ─── Modern CLI replacements ─────────────────────────────────────────────────
echo ""
echo "── Modern CLI replacements ──"
brw lsd
brw bat
brw ripgrep rg
brw fd
brw btop
brw dust
brw procs
brw yazi
brw xh
brw lazygit
brw gitui
brw bottom btm
brw dua-cli dua
brw sk                          # skim
brw git-delta delta
brw hyperfine
brw tealdeer tldr
brw watchexec
brw topgrade

# ─── Git & GitHub tools ──────────────────────────────────────────────────────
echo ""
echo "── Git tools ──"
brw gh
brw navi

# ─── Navigation & search ─────────────────────────────────────────────────────
echo ""
echo "── Navigation & search ──"
brw jq
brw yq
brw fx

# ─── Runtimes ────────────────────────────────────────────────────────────────
echo ""
echo "── Runtimes ──"

# Rust
if ! has cargo; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"
fi

# nvm + Node
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm install --lts
    green "  nvm + Node LTS installed"
else
    info "already installed: nvm"
fi

brw bun
brw pyenv
brw uv
brw pipx
brw mise

# ─── Productivity ─────────────────────────────────────────────────────────────
echo ""
echo "── Productivity ──"
brw task taskwarrior
brw timew timewarrior
brw just
brw entr
brw pet

# ─── thefuck ─────────────────────────────────────────────────────────────────
echo ""
echo "── thefuck ──"
if ! has thefuck; then
    python3 -m venv "$HOME/.thefuck-env"
    "$HOME/.thefuck-env/bin/pip" install thefuck
    green "  thefuck installed in ~/.thefuck-env"
else
    info "already installed: thefuck"
fi

# ─── Docker tools ────────────────────────────────────────────────────────────
echo ""
echo "── Docker tools ──"
brw ctop
brw lazydocker

# ─── TUI tools ───────────────────────────────────────────────────────────────
echo ""
echo "── TUI tools ──"
brw macchina
brw fastfetch

# ─── Database ────────────────────────────────────────────────────────────────
echo ""
echo "── Database ──"
brw pgcli

# ─── Notes & knowledge ───────────────────────────────────────────────────────
echo ""
echo "── Notes & knowledge ──"
brw nb
brw dnote

# ─── Remote ──────────────────────────────────────────────────────────────────
echo ""
echo "── Remote ──"
brw mosh
brw tmate

# ─── Misc utilities ──────────────────────────────────────────────────────────
echo ""
echo "── Misc utilities ──"
brw kalker
brw atac
brw posting
brw gdu
brw lychee
brw mani

# ─── macOS extras ────────────────────────────────────────────────────────────
if $IS_MAC; then
    echo ""
    echo "── macOS extras ──"
    # pbcopy/pbpaste are built-in on macOS — no install needed
    # Prefer GNU coreutils for script compatibility
    brw coreutils
    brw gnu-sed gsed
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════"
green "Done! All packages installed."
echo ""
echo "Next steps:"
echo "  1. Run:  bash ~/.config/install.sh   (symlinks + TPM + OMZ plugins)"
echo "  2. Re-login or: exec zsh"
echo "  3. Open tmux and press Prefix+I to install tmux plugins"
echo "  4. Run:  atuin login   (optional — sync shell history)"
echo "  5. Run:  gh auth login (optional — GitHub CLI auth)"
echo ""
