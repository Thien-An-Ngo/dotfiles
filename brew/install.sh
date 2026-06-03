#!/usr/bin/env bash
# brew/install.sh — install tools used by this dotfiles repo via Homebrew
# Works on macOS (Apple Silicon & Intel) and Linux (Linuxbrew).
# Idempotent: skips anything already installed.
# Usage: bash brew/install.sh [--categories core,cli,shell,...]

set -euo pipefail

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

has() { command -v "$1" &>/dev/null; }

IS_MAC=false
[[ "$(uname -s)" == "Darwin" ]] && IS_MAC=true

# ─── Category parsing ─────────────────────────────────────────────────────────
CATEGORIES="core,cli,shell,tui,runtimes,productivity,remote,db,utils"
while [[ $# -gt 0 ]]; do
    case $1 in --categories) CATEGORIES="$2"; shift 2 ;; *) shift ;; esac
done
has_cat() { [[ ",$CATEGORIES," == *",$1,"* ]]; }

# ─── Ensure Homebrew is installed (always runs) ───────────────────────────────
if ! has brew; then
    echo ""
    echo "── Installing Homebrew ──"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if $IS_MAC; then
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
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

# ─── core ────────────────────────────────────────────────────────────────────
if has_cat core; then
    echo ""
    echo "── Core shell & build tools ──"
    brw zsh
    brw git
    brw curl
    brw wget
    brw unzip
    $IS_MAC || brw gcc make
    brw tmux
    brw starship
    brw fzf
    brw neovim nvim
    brw gh
    brw chezmoi

    # Zsh default shell
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
fi

# ─── cli ─────────────────────────────────────────────────────────────────────
if has_cat cli; then
    echo ""
    echo "── Modern CLI replacements ──"
    brw lsd
    brw bat
    brw ripgrep rg
    brw fd
    brw btop
    brw dust
    brw procs
    brw git-delta delta
    brw hyperfine
    brw tealdeer tldr
    brw watchexec
    brw topgrade
    brw dua-cli dua
    brw bottom btm
    brw xh
    brw sk
    brw jq
    brw yq
    brw fx
fi

# ─── shell ────────────────────────────────────────────────────────────────────
if has_cat shell; then
    echo ""
    echo "── Shell enhancements ──"
    brw zoxide
    brw atuin
    brw navi

    # thefuck
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
    brw yazi
    brw gitui
    brw lazydocker
    brw macchina
    brw fastfetch
    brw lazygit
fi

# ─── runtimes ────────────────────────────────────────────────────────────────
if has_cat runtimes; then
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
fi

# ─── productivity ─────────────────────────────────────────────────────────────
if has_cat productivity; then
    echo ""
    echo "── Productivity ──"
    brw task taskwarrior
    brw timew timewarrior
    brw just
    brw entr
    brw pet
fi

# ─── remote ──────────────────────────────────────────────────────────────────
if has_cat remote; then
    echo ""
    echo "── Remote ──"
    brw mosh
    brw tmate
fi

# ─── db ──────────────────────────────────────────────────────────────────────
if has_cat db; then
    echo ""
    echo "── Database ──"
    brw pgcli
fi

# ─── utils ───────────────────────────────────────────────────────────────────
if has_cat utils; then
    echo ""
    echo "── Misc utilities ──"
    brw kalker
    brw atac
    brw posting
    brw gdu
    brw lychee
    brw mani
    brw nb
    brw dnote
fi

# ─── macOS extras ────────────────────────────────────────────────────────────
if $IS_MAC; then
    echo ""
    echo "── macOS extras ──"
    brw coreutils
    brw gnu-sed gsed
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════"
green "Done! Packages installed (categories: $CATEGORIES)"
echo ""
echo "Next steps:"
echo "  1. Re-login or: exec zsh"
echo "  2. Open tmux and press Prefix+I to install tmux plugins"
echo "  3. Run:  atuin login   (optional — sync shell history)"
echo "  4. Run:  gh auth login (optional — GitHub CLI auth)"
echo ""
