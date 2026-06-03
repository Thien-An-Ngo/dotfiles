#!/usr/bin/env bash
# arch-install.sh — install every tool used by this dotfiles repo on Arch Linux
# Idempotent: skips anything already installed. Run as a normal user (sudo will be prompted).

set -euo pipefail

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

has() { command -v "$1" &>/dev/null; }

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

# ─── Core shell & build tools ────────────────────────────────────────────────
echo ""
echo "── Core shell & build tools ──"
pac zsh
pac git
pac base-devel make
pac curl
pac wget
pac unzip
pac man-db man

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

# ─── Terminal multiplexer ────────────────────────────────────────────────────
echo ""
echo "── Tmux ──"
pac tmux

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    green "  TPM installed (run Prefix+I inside tmux to install plugins)"
else
    info "already installed: tpm"
fi

# ─── Prompt & shell enhancements ─────────────────────────────────────────────
echo ""
echo "── Prompt & shell enhancements ──"
pac starship
pac fzf
pac zoxide
pac atuin

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
if ! has nvim; then
    yay -S --needed --noconfirm neovim-git
else
    info "already installed: nvim"
fi

# ─── Rust / Cargo (needed before cargo-installed tools) ──────────────────────
echo ""
echo "── Rust ──"
if ! has cargo; then
    pac rust cargo
fi

# ─── Modern CLI replacements ─────────────────────────────────────────────────
echo ""
echo "── Modern CLI replacements ──"
pac lsd
pac bat
pac ripgrep rg
pac fd
pac btop
aur dust-bin dust
pac procs
aur yazi-bin yazi
aur xh-bin xh
pac lazygit
aur gitui gitui
aur bottom-bin btm
aur dua-cli dua
aur skim sk
pac git-delta delta
pac hyperfine
pac tealdeer tldr
aur watchexec-bin watchexec
aur topgrade-bin topgrade

# ─── Git & GitHub tools ──────────────────────────────────────────────────────
echo ""
echo "── Git tools ──"
pac github-cli gh
pac navi

# ─── Navigation & search ─────────────────────────────────────────────────────
echo ""
echo "── Navigation & search ──"
pac jq
aur yq-go yq
aur fx

# ─── Runtimes ────────────────────────────────────────────────────────────────
echo ""
echo "── Runtimes ──"

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

# Python / pyenv
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

# ─── Productivity ─────────────────────────────────────────────────────────────
echo ""
echo "── Productivity ──"
aur taskwarrior task
aur timewarrior timew
aur just
pac entr
aur pet-git pet

# ─── thefuck (venv to avoid polluting system Python) ─────────────────────────
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
aur ctop-bin ctop
aur lazydocker-bin lazydocker

# ─── TUI tools ───────────────────────────────────────────────────────────────
echo ""
echo "── TUI tools ──"
aur macchina-bin macchina
aur fastfetch-bin fastfetch

# ─── Database ────────────────────────────────────────────────────────────────
echo ""
echo "── Database ──"
aur pgcli

# ─── Notes & knowledge ───────────────────────────────────────────────────────
echo ""
echo "── Notes & knowledge ──"
aur nb
aur dnote-bin dnote

# ─── Remote ──────────────────────────────────────────────────────────────────
echo ""
echo "── Remote ──"
pac mosh
aur tmate

# ─── Misc utilities ──────────────────────────────────────────────────────────
echo ""
echo "── Misc utilities ──"
aur has
pac kalker
aur atac-bin atac
aur posting posting
aur gdu-go gdu
aur mani
pac lychee

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
