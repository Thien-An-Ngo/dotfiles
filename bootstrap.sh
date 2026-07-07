#!/usr/bin/env bash
# bootstrap.sh — curl-able fresh machine setup
# Usage: sh -c "$(curl -fsLS https://raw.githubusercontent.com/Thien-An-Ngo/dotfiles/main/bootstrap.sh)"

set -euo pipefail

DOTFILES_URL_SSH="git@github.com:Thien-An-Ngo/dotfiles.git"
DOTFILES_URL_HTTPS="https://github.com/Thien-An-Ngo/dotfiles.git"

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }
ask()    { printf '\033[0;36m%s\033[0m ' "$*"; }

has() { command -v "$1" &>/dev/null; }

echo ""
bold "════════════════════════════════════════"
bold "  dotfiles bootstrap"
bold "════════════════════════════════════════"
echo ""

# ── Detect OS ────────────────────────────────────────────────────────────────
OS="$(uname -s)"
DISTRO=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO="${ID:-}"
fi

# ── Install git + chezmoi ────────────────────────────────────────────────────
bold "── Installing dependencies ──"

install_deps() {
    case "$DISTRO" in
        arch)
            sudo pacman -S --needed --noconfirm git chezmoi ;;
        ubuntu|debian)
            sudo apt-get update -y
            sudo apt-get install -y git
            if ! has chezmoi; then
                sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
            fi ;;
        *)
            if [ "$OS" = "Darwin" ]; then
                if ! has brew; then
                    echo "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                fi
                brew install git chezmoi
            else
                yellow "Unknown distro — installing chezmoi via official script"
                if ! has chezmoi; then
                    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
                fi
            fi ;;
    esac
}

install_deps
green "  git and chezmoi ready"

# ── SSH key setup (optional) ─────────────────────────────────────────────────
echo ""
ask "[ ] Set up SSH key for GitHub? (recommended for pushing) [y/N]"
read -r SSH_CHOICE

USE_SSH=false
if [ "${SSH_CHOICE:-n}" = "y" ] || [ "${SSH_CHOICE:-n}" = "Y" ]; then
    USE_SSH=true
    bold "── SSH key setup ──"

    SSH_KEY="$HOME/.ssh/id_ed25519"
    if [ -f "$SSH_KEY" ]; then
        yellow "  Existing key found: $SSH_KEY"
    else
        ask "  Email for SSH key:"
        read -r SSH_EMAIL
        ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY" -N ""
        green "  Key generated: $SSH_KEY"
    fi

    PUBKEY="$(cat "${SSH_KEY}.pub")"
    echo ""
    bold "  Your public key:"
    echo ""
    echo "  $PUBKEY"
    echo ""

    # Copy to clipboard if possible
    if has clip.exe; then
        echo "$PUBKEY" | clip.exe
        green "  Copied to clipboard (clip.exe)"
    elif has wl-copy; then
        echo "$PUBKEY" | wl-copy
        green "  Copied to clipboard (wl-copy)"
    elif has xclip; then
        echo "$PUBKEY" | xclip -selection clipboard
        green "  Copied to clipboard (xclip)"
    elif has pbcopy; then
        echo "$PUBKEY" | pbcopy
        green "  Copied to clipboard (pbcopy)"
    else
        yellow "  Could not copy to clipboard — copy the key above manually"
    fi

    echo ""
    bold "  Add it at: https://github.com/settings/ssh/new"
    echo ""
    ask "  Press Enter once you've added the key..."
    read -r

    # Test connection — GitHub exits 1 even on success, output goes to stderr
    bold "  Testing GitHub SSH connection..."
    TRIES=0
    while [ $TRIES -lt 5 ]; do
        SSH_OUT="$(ssh -o StrictHostKeyChecking=accept-new -T git@github.com 2>&1 || true)"
        if echo "$SSH_OUT" | grep -q "successfully authenticated"; then
            green "  SSH connection confirmed"
            break
        fi
        TRIES=$((TRIES + 1))
        if [ $TRIES -lt 5 ]; then
            yellow "  Not confirmed yet — retrying in 3s (${TRIES}/5)..."
            sleep 3
        else
            yellow "  Could not confirm SSH — falling back to HTTPS"
            USE_SSH=false
        fi
    done
fi

# ── Run chezmoi ───────────────────────────────────────────────────────────────
echo ""
bold "── Initialising dotfiles ──"

if [ "$USE_SSH" = true ]; then
    URL="$DOTFILES_URL_SSH"
else
    URL="$DOTFILES_URL_HTTPS"
fi

echo "  Using: $URL"
echo ""

chezmoi init --apply "$URL"

echo ""
bold "════════════════════════════════════════"
green "  Done! Re-login or run: exec zsh"
bold "════════════════════════════════════════"
echo ""
