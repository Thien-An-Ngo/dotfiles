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
    aur chezmoi

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
    aur dust-bin dust
    pac procs
    aur git-delta delta
    pac hyperfine
    pac tealdeer tldr
    aur watchexec-bin watchexec
    aur topgrade-bin topgrade
    aur dua-cli dua
    aur bottom-bin btm
    aur xh-bin xh
    aur skim sk
    pac jq
    aur yq-go yq
    aur fx
fi

# ─── shell ───────────────────────────────────────────────────────────────────
if has_cat shell; then
    echo ""
    echo "── Shell enhancements ──"
    pac zoxide
    pac atuin
    pac navi

    echo ""
    echo "── thefuck ──"
    if ! has thefuck; then
        python3 -m venv "$HOME/.thefuck-env"
        "$HOME/.thefuck-env/bin/pip" install thefuck
        green "  thefuck installed in ~/.thefuck-env"
    else
        info "already installed: thefuck"
    fi
fi

# ─── tui ─────────────────────────────────────────────────────────────────────
if has_cat tui; then
    echo ""
    echo "── TUI tools ──"
    aur yazi-bin yazi
    aur gitui gitui
    aur lazydocker-bin lazydocker
    aur macchina-bin macchina
    aur fastfetch-bin fastfetch
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
        aur bun-bin bun
    fi

    # pyenv
    if ! has pyenv; then
        aur pyenv
    fi

    # uv
    if ! has uv; then
        aur uv
    fi

    # pipx
    if ! has pipx; then
        pac python-pipx pipx
    fi

    # mise
    if ! has mise; then
        aur mise
    fi
fi

# ─── productivity ─────────────────────────────────────────────────────────────
if has_cat productivity; then
    echo ""
    echo "── Productivity ──"
    aur taskwarrior task
    aur timewarrior timew
    aur just
    pac entr
    aur pet-git pet
fi

# ─── remote ──────────────────────────────────────────────────────────────────
if has_cat remote; then
    echo ""
    echo "── Remote ──"
    pac mosh
    aur tmate
fi

# ─── db ──────────────────────────────────────────────────────────────────────
if has_cat db; then
    echo ""
    echo "── Database ──"
    aur pgcli
fi

# ─── utils ───────────────────────────────────────────────────────────────────
if has_cat utils; then
    echo ""
    echo "── Misc utilities ──"
    aur atac-bin atac
    aur posting posting
    aur gdu-go gdu
    aur mani
    pac lychee
    pac kalker
    aur nb
    aur dnote-bin dnote
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
