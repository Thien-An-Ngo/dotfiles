#!/usr/bin/env bash
# arch/uninstall.sh — revert everything bootstrap.sh + arch/install.sh did
# Run as a normal user (sudo will be prompted where needed).

set -euo pipefail

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }
ask()    { printf '\033[0;36m%s\033[0m ' "$*"; }

has() { command -v "$1" &>/dev/null; }

rem_pac() {
    if pacman -Q "$1" &>/dev/null; then
        echo "  [pacman] removing $1"
        sudo pacman -Rns --noconfirm "$1" 2>/dev/null || true
    fi
}

rem_yay() {
    if pacman -Q "$1" &>/dev/null; then
        echo "  [yay] removing $1"
        yay -Rns --noconfirm "$1" 2>/dev/null || true
    fi
}

echo ""
bold "════════════════════════════════════════"
bold "  dotfiles uninstall"
bold "════════════════════════════════════════"
echo ""
yellow "This will remove all packages and config installed by bootstrap + arch/install.sh."
ask "Continue? [y/N]"
read -r CONFIRM
[ "${CONFIRM:-n}" = "y" ] || [ "${CONFIRM:-n}" = "Y" ] || { echo "Aborted."; exit 0; }

# ── Revert default shell ───────────────────────────────────────────────────
echo ""
bold "── Reverting default shell ──"
if [ "$SHELL" = "$(which zsh 2>/dev/null)" ]; then
    BASH_PATH="$(which bash)"
    chsh -s "$BASH_PATH"
    green "  default shell reverted to bash (re-login to take effect)"
fi

# ── Remove chezmoi-managed dotfiles ───────────────────────────────────────
echo ""
bold "── Removing chezmoi-managed dotfiles ──"
if has chezmoi; then
    chezmoi purge --force 2>/dev/null || true
    green "  chezmoi dotfiles purged"
fi
rm -rf \
    "$HOME/.local/share/chezmoi" \
    "$HOME/.config/chezmoi" \
    "$HOME/.zshrc" \
    "$HOME/.zshenv" \
    "$HOME/.zprofile" \
    "$HOME/.tmux.conf" \
    "$HOME/.gitconfig" \
    "$HOME/.config/starship.toml" \
    "$HOME/.config/btop" \
    "$HOME/.config/neofetch" \
    "$HOME/.config/thefuck" \
    "$HOME/.config/micro" \
    "$HOME/.config/gh" \
    "$HOME/.config/pypoetry" \
    2>/dev/null || true

# ── Remove shell extras ───────────────────────────────────────────────────
echo ""
bold "── Removing shell extras ──"
rm -rf "$HOME/.oh-my-zsh"
rm -rf "$HOME/.tmux"
rm -rf "$HOME/.thefuck-env"
green "  oh-my-zsh, tmux plugins, thefuck venv removed"

# ── Remove runtimes ───────────────────────────────────────────────────────
echo ""
bold "── Removing runtimes ──"

if [ -d "$HOME/.nvm" ]; then
    rm -rf "$HOME/.nvm"
    green "  nvm removed"
fi

if [ -d "$HOME/.cargo" ]; then
    if has rustup; then
        rustup self uninstall -y 2>/dev/null || true
    else
        rm -rf "$HOME/.cargo" "$HOME/.rustup"
    fi
    green "  rust/cargo removed"
fi

if [ -d "$HOME/.pyenv" ]; then
    rm -rf "$HOME/.pyenv"
    green "  pyenv removed"
fi

if [ -d "$HOME/.local/share/mise" ] || has mise; then
    rm -rf "$HOME/.local/share/mise" "$HOME/.config/mise"
    green "  mise removed"
fi

if has bun || [ -d "$HOME/.bun" ]; then
    "$HOME/.bun/bin/bun" completions --uninstall 2>/dev/null || true
    rm -rf "$HOME/.bun"
    green "  bun removed"
fi

# ── Remove AUR packages ───────────────────────────────────────────────────
echo ""
bold "── Removing AUR packages ──"
for pkg in \
    chezmoi dust-bin git-delta watchexec-bin topgrade-bin dua-cli bottom-bin \
    xh-bin skim yq-go fx yazi-bin gitui lazydocker-bin macchina-bin \
    fastfetch-bin bun-bin pyenv uv mise taskwarrior timewarrior just \
    pet-git tmate pgcli atac-bin posting gdu-go mani nb dnote-bin \
    yay-bin; do
    rem_yay "$pkg"
done

# ── Remove pacman packages ─────────────────────────────────────────────────
echo ""
bold "── Removing pacman packages ──"
for pkg in \
    zsh tmux starship fzf neovim github-cli \
    lsd bat ripgrep fd btop procs hyperfine tealdeer jq \
    zoxide atuin navi \
    lazygit \
    rust cargo python-pipx \
    mosh \
    wl-clipboard xclip lychee kalker entr \
    man-db wget unzip curl; do
    rem_pac "$pkg"
done

# ── Remove yay itself ─────────────────────────────────────────────────────
echo ""
bold "── Removing yay ──"
rem_yay yay-bin
rem_pac yay

# ── Remove SSH key (optional) ─────────────────────────────────────────────
echo ""
ask "Remove SSH key (~/.ssh/id_ed25519)? [y/N]"
read -r SSH_CHOICE
if [ "${SSH_CHOICE:-n}" = "y" ] || [ "${SSH_CHOICE:-n}" = "Y" ]; then
    rm -f "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_ed25519.pub"
    green "  SSH key removed"
fi

# ── Remove leftover dotfile dirs ──────────────────────────────────────────
echo ""
bold "── Cleaning up leftover dirs ──"
rm -rf \
    "$HOME/.local/bin/chezmoi" \
    "$HOME/.local/bin/starship" \
    "$HOME/.config/atuin" \
    "$HOME/.config/zoxide" \
    "$HOME/.config/navi" \
    "$HOME/.config/lazygit" \
    "$HOME/.config/yazi" \
    "$HOME/.config/gitui" \
    "$HOME/.atuin" \
    2>/dev/null || true

echo ""
bold "════════════════════════════════════════"
green "Done! Re-login or open a new WSL session."
bold "════════════════════════════════════════"
echo ""
