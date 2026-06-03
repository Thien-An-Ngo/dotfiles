#!/usr/bin/env bash
# nix-install.sh — install Nix package manager + home-manager on any Linux/macOS
# Then applies nix-manager/home.nix to install all dotfile tools declaratively.
# Idempotent: safe to re-run.

set -euo pipefail

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

has() { command -v "$1" &>/dev/null; }

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Install Nix ─────────────────────────────────────────────────────────────
echo ""
echo "── Nix ──"
if ! has nix; then
    echo "  Installing Nix (multi-user)..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
        sh -s -- install --no-confirm
    # Source nix for this session
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    green "  Nix installed"
else
    info "already installed: nix"
fi

# Enable flakes + nix-command (required for home-manager)
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

# Symlink our home.nix into the home-manager config dir
mkdir -p "$(dirname "$HOME_NIX_DST")"
if [ ! -L "$HOME_NIX_DST" ] || [ "$(readlink "$HOME_NIX_DST")" != "$HOME_NIX_SRC" ]; then
    ln -sf "$HOME_NIX_SRC" "$HOME_NIX_DST"
    green "  linked $HOME_NIX_DST → $HOME_NIX_SRC"
fi

home-manager switch
green "  home-manager switch complete"

# ─── Oh My Zsh (not in nixpkgs, installed separately) ────────────────────────
echo ""
echo "── Oh My Zsh ──"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    green "  oh-my-zsh installed"
else
    info "already installed: oh-my-zsh"
fi

# fzf-tab
FZF_TAB_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
if [ ! -d "$FZF_TAB_DIR" ]; then
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
    green "  fzf-tab installed"
else
    info "already installed: fzf-tab"
fi

# forgit
FORGIT_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/forgit"
if [ ! -d "$FORGIT_DIR" ]; then
    git clone https://github.com/wfxr/forgit "$FORGIT_DIR"
    green "  forgit installed"
else
    info "already installed: forgit"
fi

# ─── TPM ─────────────────────────────────────────────────────────────────────
echo ""
echo "── TPM ──"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    green "  TPM installed (run Prefix+I inside tmux to install plugins)"
else
    info "already installed: tpm"
fi

# ─── nvm + Node (not managed by nix to avoid conflicts) ──────────────────────
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

# ─── thefuck (pip venv — nix's python isolation makes this cleaner outside nix)
echo ""
echo "── thefuck ──"
if ! has thefuck; then
    python3 -m venv "$HOME/.thefuck-env"
    "$HOME/.thefuck-env/bin/pip" install thefuck
    green "  thefuck installed in ~/.thefuck-env"
else
    info "already installed: thefuck"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════"
green "Done!"
echo ""
echo "Next steps:"
echo "  1. Run:  bash ~/.config/install.sh   (symlinks + TPM + OMZ plugins)"
echo "  2. Re-login or: exec zsh"
echo "  3. Open tmux and press Prefix+I to install tmux plugins"
echo "  4. Run:  atuin login   (optional)"
echo "  5. Run:  gh auth login (optional)"
echo ""
