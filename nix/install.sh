#!/usr/bin/env bash
# nix/install.sh — install Nix package manager + home-manager, then apply home.nix
# Idempotent: safe to re-run.
# Usage: bash nix/install.sh [--categories core,cli,shell,...]

set -euo pipefail

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

has() { command -v "$1" &>/dev/null; }

# ─── Category parsing ─────────────────────────────────────────────────────────
CATEGORIES="core,cli,shell,tui,runtimes,productivity,remote,db,utils"
while [[ $# -gt 0 ]]; do
    case $1 in --categories) CATEGORIES="$2"; shift 2 ;; *) shift ;; esac
done
has_cat() { [[ ",$CATEGORIES," == *",$1,"* ]]; }

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ─── Install Nix (always runs) ────────────────────────────────────────────────
echo ""
echo "── Nix ──"
if ! has nix; then
    echo "  Installing Nix (multi-user)..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
        sh -s -- install --no-confirm
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    green "  Nix installed"
else
    info "already installed: nix"
fi

# Enable flakes + nix-command
NIX_CONF="$HOME/.config/nix/nix.conf"
mkdir -p "$(dirname "$NIX_CONF")"
if ! grep -q "experimental-features" "$NIX_CONF" 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> "$NIX_CONF"
    green "  enabled flakes + nix-command"
fi

# ─── Install home-manager ─────────────────────────────────────────────────────
echo ""
echo "── home-manager ──"
if ! has home-manager; then
    nix run home-manager/master -- init --switch
    green "  home-manager bootstrapped"
else
    info "already installed: home-manager"
fi

# ─── Apply nix-manager/home.nix ──────────────────────────────────────────────
echo ""
echo "── Applying home.nix ──"
HOME_NIX_SRC="$DOTFILES/nix-manager/home.nix"
HOME_NIX_DST="$HOME/.config/home-manager/home.nix"

mkdir -p "$(dirname "$HOME_NIX_DST")"
if [ ! -L "$HOME_NIX_DST" ] || [ "$(readlink "$HOME_NIX_DST")" != "$HOME_NIX_SRC" ]; then
    ln -sf "$HOME_NIX_SRC" "$HOME_NIX_DST"
    green "  linked $HOME_NIX_DST → $HOME_NIX_SRC"
fi

home-manager switch
green "  home-manager switch complete"

# ─── shell extras (not fully managed by nix) ─────────────────────────────────
if has_cat shell; then
    echo ""
    echo "── Shell enhancements ──"

    # thefuck (pip venv — cleaner outside nix)
    if ! has thefuck; then
        python3 -m venv "$HOME/.thefuck-env"
        "$HOME/.thefuck-env/bin/pip" install thefuck
        green "  thefuck installed in ~/.thefuck-env"
    else
        info "already installed: thefuck"
    fi
fi

# ─── runtimes (not managed by nix to avoid conflicts) ────────────────────────
if has_cat runtimes; then
    echo ""
    echo "── nvm ──"
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install --lts
        green "  nvm + Node LTS installed"
    else
        info "already installed: nvm"
    fi
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════"
green "Done! (categories: $CATEGORIES)"
echo ""
echo "Next steps:"
echo "  1. Re-login or: exec zsh"
echo "  2. Open tmux and press Prefix+I to install tmux plugins"
echo "  3. Run:  atuin login   (optional)"
echo "  4. Run:  gh auth login (optional)"
echo ""
