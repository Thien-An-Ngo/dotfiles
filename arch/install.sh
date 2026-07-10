#!/usr/bin/env bash
# arch/install.sh — install tools used by this dotfiles repo on Arch Linux
# Idempotent: skips anything already installed. Run as a normal user (sudo will be prompted).
# Usage: bash arch/install.sh [--categories core,cli,shell,...]

set -euo pipefail

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

has() { command -v "$1" &>/dev/null; }

# ─── Category filtering ───────────────────────────────────────────────────────
CATEGORIES="core,cli,shell,tui,runtimes,productivity,remote,db,utils"
while [[ $# -gt 0 ]]; do
    case $1 in --categories) CATEGORIES="$2"; shift 2 ;; *) shift ;; esac
done
has_cat() { [[ ",$CATEGORIES," == *",$1,"* ]]; }

# ─── Ensure yay is available ─────────────────────────────────────────────────
if ! has yay; then
    echo ""
    echo "── Installing yay (AUR helper) ──"
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    (cd /tmp/yay-bin && makepkg -si --noconfirm)
    rm -rf /tmp/yay-bin
    green "  yay installed"
fi

# ─── Helper: install from pacman if not present ──────────────────────────────
pac() {
    local pkg="$1"
    local bin="${2:-$1}"
    if has "$bin"; then
        info "already installed: $bin"
    else
        echo "  [pacman] $pkg"
        sudo pacman -S --needed --noconfirm "$pkg"
    fi
}

# ─── Helper: install from AUR if not present ─────────────────────────────────
aur() {
    local pkg="$1"
    local bin="${2:-$1}"
    if has "$bin"; then
        info "already installed: $bin"
    else
        echo "  [aur] $pkg"
        yay -S --needed --noconfirm "$pkg"
    fi
}

# ─── System update ───────────────────────────────────────────────────────────
echo ""
echo "── System update ──"
sudo pacman -Syu --noconfirm

# ─── core ────────────────────────────────────────────────────────────────────
if has_cat core; then
    echo ""
    echo "── Core shell & build tools ──"
    pac zsh
    pac git
    pac base-devel make
    pac curl
    pac wget
    pac unzip
    pac man-db man
    pac tmux
    pac starship
    pac fzf
    pac neovim nvim
    pac github-cli gh
    pac chezmoi

    echo ""
    echo "── Default shell ──"
    ZSH_PATH="$(which zsh)"
    if ! grep -qxF "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
        green "  added $ZSH_PATH to /etc/shells"
    fi
    if [ "$SHELL" != "$ZSH_PATH" ]; then
        chsh -s "$ZSH_PATH"
        green "  default shell set to zsh (re-login to take effect)"
    else
        info "already default: zsh"
    fi
fi

# ─── cli ─────────────────────────────────────────────────────────────────────
if has_cat cli; then
    echo ""
    echo "── Modern CLI tools ──"
    pac lsd
    pac bat
    pac ripgrep rg
    pac fd
    pac btop
    pac dust dust
    pac procs
    pac git-delta delta
    pac hyperfine
    pac tealdeer tldr
    pac watchexec
    aur topgrade-bin topgrade
    pac dua-cli dua
    pac bottom btm
    pac xh
    pac skim sk
    pac jq
    pac go-yq yq
    pac fx
fi

# ─── shell ───────────────────────────────────────────────────────────────────
if has_cat shell; then
    echo ""
    echo "── Shell enhancements ──"
    pac zoxide
    pac atuin
    pac navi

fi

# ─── tui ─────────────────────────────────────────────────────────────────────
if has_cat tui; then
    echo ""
    echo "── TUI tools ──"
    pac yazi
    pac gitui
    pac lazydocker
    pac macchina
    pac fastfetch
    pac lazygit
fi

# ─── runtimes ────────────────────────────────────────────────────────────────
if has_cat runtimes; then
    echo ""
    echo "── Runtimes ──"

    # Rust
    if ! has cargo; then
        pac rust cargo
    fi

    # nvm + Node
    if [ ! -d "$HOME/.nvm" ]; then
        echo "  [nvm] installing..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install --lts
        green "  nvm + Node LTS installed"
    else
        info "already installed: nvm"
    fi

    # Bun
    if ! has bun; then
        pac bun
    fi

    # Claude Code (requires nvm node in PATH)
    if ! has claude; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        npm install -g @anthropic-ai/claude-code
        green "  claude-code installed"
    else
        info "already installed: claude"
    fi

    # pyenv
    if ! has pyenv; then
        pac pyenv
    fi

    # uv
    if ! has uv; then
        pac uv
    fi

    # pipx
    if ! has pipx; then
        pac python-pipx pipx
    fi

    # mise
    if ! has mise; then
        pac mise
    fi
fi

# ─── productivity ─────────────────────────────────────────────────────────────
if has_cat productivity; then
    echo ""
    echo "── Productivity ──"
    pac task task
    pac timew timew
    pac just
    pac entr
    aur pet-git pet
fi

# ─── remote ──────────────────────────────────────────────────────────────────
if has_cat remote; then
    echo ""
    echo "── Remote ──"
    pac mosh
    pac tmate
fi

# ─── db ──────────────────────────────────────────────────────────────────────
if has_cat db; then
    echo ""
    echo "── Database ──"
    pac pgcli
fi

# ─── utils ───────────────────────────────────────────────────────────────────
if has_cat utils; then
    echo ""
    echo "── Misc utilities ──"
    pac wl-clipboard wl-copy
    pac xclip
    pac atac
    aur posting posting
    pac gdu
    aur mani
    pac lychee
    aur kalker-bin kalker
    aur nb
    aur dnote-cli-bin dnote
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════"
green "Done! All packages installed."
echo ""
echo "Next steps:"
echo "  1. Re-login or: exec zsh"
echo "  2. Open tmux and press Prefix+I to install tmux plugins"
echo "  3. Run:  atuin login   (optional — sync shell history)"
echo "  4. Run:  gh auth login (optional — GitHub CLI auth)"
echo ""
