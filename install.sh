#!/usr/bin/env bash
# install.sh — set up symlinks for all tracked dotfiles
# Idempotent: re-running is safe. Existing files are backed up, not overwritten.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
BACKED_UP=0

# Ensure submodules (e.g. nvim) are initialised
git -C "$DOTFILES" submodule update --init --recursive

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

link() {
    local src="$DOTFILES/$1"   # absolute path inside the repo
    local dst="$2"             # destination (e.g. ~/.zshrc)

    # Already a correct symlink — skip
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        info "already linked: $dst"
        return
    fi

    # File/dir exists but is not a symlink — back up
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        BACKED_UP=1
        yellow "  backed up: $dst → $BACKUP_DIR/$(basename "$dst")"
    fi

    # Stale symlink pointing nowhere — remove it
    if [ -L "$dst" ]; then
        rm "$dst"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    green "  linked: $dst"
}

# ─── Home dotfiles ────────────────────────────────────────────────────────────
echo ""
echo "── Home dotfiles ──"
link home/.zshrc      "$HOME/.zshrc"
link home/.zshenv     "$HOME/.zshenv"
link home/.zprofile   "$HOME/.zprofile"
link home/.tmux.conf  "$HOME/.tmux.conf"
link home/.gitconfig  "$HOME/.gitconfig"

# ─── Claude Code settings ────────────────────────────────────────────────────
echo ""
echo "── Claude Code ──"
mkdir -p "$HOME/.claude"
link claude/settings.json "$HOME/.claude/settings.json"

# ─── ~/.config entries that need explicit symlinking ─────────────────────────
# (Most ~/.config/* are already in the right place since this repo IS ~/.config)
# Add entries here if you ever move the repo to ~/dotfiles instead.

# ─── Tool installation checks ────────────────────────────────────────────────
echo ""
echo "── Checking tools ──"

check() {
    if command -v "$1" &>/dev/null; then
        green "  ✓ $1"
    else
        red "  ✗ $1  — not installed (see README for install command)"
    fi
}

check zsh
check tmux
check starship
check fzf
check zoxide
check nvim
check lazygit
check lsd
check bat
check rg
check fd
check btop
check dust
check procs
check thefuck
check fastfetch
check nvm || check node
check bun
check gh

# ─── TPM (tmux plugin manager) ───────────────────────────────────────────────
echo ""
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "── Installing TPM ──"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    green "  TPM installed. Inside tmux run: Prefix + I  to install plugins."
else
    green "  ✓ TPM already installed"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════"
green "Done!"
if [ "$BACKED_UP" = "1" ]; then
    yellow "Original files were backed up to: $BACKUP_DIR"
fi
echo ""
echo "Next steps:"
echo "  1. Reload shell:        source ~/.zshrc"
echo "  2. Reload tmux config:  Prefix + r  (or: tmux source-file ~/.tmux.conf)"
echo "  3. Install tmux plugins inside tmux:  Prefix + I"
echo ""
