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

# shell
check zsh
check starship
check fzf
check zoxide
check atuin

# terminal
check tmux

# editors
check nvim

# runtimes
check cargo
check rustup

# modern CLI replacements
check lsd
check bat
check rg
check fd
check btop
check dust
check procs
check yazi
check xh
check macchina
check thefuck
check fastfetch

# version control
check lazygit
check gh

# runtimes
check nvm 2>/dev/null || check node
check bun

# productivity
check task
check timew
check just
check entr
check pet

# docker
check ctop
check lazydocker

# remote
check mosh
check tmate
check xxh

# database
check pgcli

# notes & knowledge
check nb
check dnote
check taskbook
check eureka

# cheatsheets & command search
check navi
check intelli-shell

# modern ls
check eza

# disk usage
check gdu

# API clients
check posting
check atac
check jwt-ui

# git tools
check forgit

# multi-repo
check mani

# networking & web
check lychee
check cariddi
check dirsearch

# remote
check mosh
check tmate
check xxh
check lazyssh

# finance
check bagels

# backup
check gobackup

# systemd
check isd

# calculator
check kalker

# CSV / data
check xan

# publishing
check surge

# docker & build
check depot
check ctop
check lazydocker

# faster alternatives & essentials
check mise      # replaces nvm + pyenv (auto-activates in .zshrc if present)
check uv        # replaces pip/pipx; aliased as pip/pipx
check delta     # git diff pager; wired into .gitconfig
check tealdeer  # rust tldr; same binary name, instant startup
check watchexec # rust entr; aliased as watch
check gitui     # rust lazygit; aliased as gu
check btm       # rust btop; aliased as top (falls back to btop)
check dua       # rust dust; aliased as du (falls back to dust)
check skim      # rust fzf alternative
check jq
check yq
check fx
check hyperfine # aliased as bench
check topgrade  # aliased as upgrade

# database
check pgcli

# environment
check envio

# utilities
check tldr
check has
check yank
check bcal
check mklicense
check themer

# ─── TPM (tmux plugin manager) ───────────────────────────────────────────────
echo ""
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "── Installing TPM ──"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    green "  TPM installed. Inside tmux run: Prefix + I  to install plugins."
else
    green "  ✓ TPM already installed"
fi

# ─── fzf-tab (Oh My Zsh plugin) ──────────────────────────────────────────────
echo ""
FZF_TAB_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    echo "── Installing fzf-tab ──"
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
    green "  fzf-tab installed."
else
    green "  ✓ fzf-tab already installed"
fi

# ─── forgit (Oh My Zsh plugin) ───────────────────────────────────────────────
echo ""
FORGIT_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/forgit"
if [ ! -d "$FORGIT_DIR" ]; then
    echo "── Installing forgit ──"
    git clone https://github.com/wfxr/forgit "$FORGIT_DIR"
    green "  forgit installed."
else
    green "  ✓ forgit already installed"
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
echo "  1. Reload shell:           source ~/.zshrc"
echo "  2. Reload tmux config:     Prefix + r  (or: tmux source-file ~/.tmux.conf)"
echo "  3. Install tmux plugins:   inside tmux → Prefix + I"
echo "  4. Sync shell history:     atuin login  (optional)"
echo ""
