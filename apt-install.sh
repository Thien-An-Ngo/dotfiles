#!/usr/bin/env bash
# apt-install.sh — install every tool used by this dotfiles repo on Debian/Ubuntu
# Idempotent: skips anything already installed. Run as a normal user (sudo will be prompted).

set -euo pipefail

green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
info()   { printf '  %s\n' "$*"; }

has() { command -v "$1" &>/dev/null; }

# ─── Helper: install from apt if not present ─────────────────────────────────
apt_pkg() {
    local pkg="$1"
    local bin="${2:-$1}"
    if has "$bin"; then
        info "already installed: $bin"
    else
        echo "  [apt] $pkg"
        sudo apt-get install -y "$pkg"
    fi
}

# ─── Helper: install a .deb from a URL ───────────────────────────────────────
deb_url() {
    local bin="$1"
    local url="$2"
    if has "$bin"; then
        info "already installed: $bin"
    else
        echo "  [deb] $bin"
        local tmp
        tmp="$(mktemp /tmp/XXXXXX.deb)"
        curl -fsSL "$url" -o "$tmp"
        sudo dpkg -i "$tmp"
        rm -f "$tmp"
    fi
}

# ─── Helper: install via cargo if not present ────────────────────────────────
crg() {
    local crate="$1"
    local bin="${2:-$1}"
    if has "$bin"; then
        info "already installed: $bin"
    else
        echo "  [cargo] $crate"
        cargo install "$crate"
    fi
}

# ─── Helper: install via pip into isolated venv ──────────────────────────────
pipvenv() {
    local pkg="$1"
    local bin="$2"
    local venv="$HOME/.${pkg}-env"
    if has "$bin"; then
        info "already installed: $bin"
    else
        echo "  [pipvenv] $pkg → $venv"
        python3 -m venv "$venv"
        "$venv/bin/pip" install "$pkg"
        green "  $pkg installed in $venv — add $venv/bin to PATH if needed"
    fi
}

# ─── System update ───────────────────────────────────────────────────────────
echo ""
echo "── System update ──"
sudo apt-get update -y
sudo apt-get upgrade -y

# ─── Core shell & build tools ────────────────────────────────────────────────
echo ""
echo "── Core shell & build tools ──"
apt_pkg zsh
apt_pkg git
apt_pkg build-essential make
apt_pkg curl
apt_pkg wget
apt_pkg unzip
apt_pkg man-db man
apt_pkg python3
apt_pkg python3-pip pip3
apt_pkg python3-venv

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
apt_pkg tmux

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    green "  TPM installed (run Prefix+I inside tmux to install plugins)"
else
    info "already installed: tpm"
fi

# ─── Prompt & shell enhancements ─────────────────────────────────────────────
echo ""
echo "── Prompt & shell enhancements ──"

# starship
if ! has starship; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# fzf
apt_pkg fzf

# zoxide
if ! has zoxide; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# atuin
if ! has atuin; then
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi

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
    # Install latest stable via PPA (Ubuntu) or download appimage
    if grep -qi ubuntu /etc/os-release 2>/dev/null; then
        sudo add-apt-repository ppa:neovim-ppa/stable -y
        sudo apt-get update -y
        sudo apt-get install -y neovim
    else
        # Debian: grab the appimage
        curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
            | sudo tar -xz -C /opt
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    fi
    green "  nvim installed"
else
    info "already installed: nvim"
fi

# ─── Modern CLI replacements ─────────────────────────────────────────────────
echo ""
echo "── Modern CLI replacements ──"

# lsd
if ! has lsd; then
    LATEST=$(curl -s https://api.github.com/repos/lsd-rs/lsd/releases/latest | grep browser_download_url | grep "amd64.deb" | cut -d '"' -f 4)
    deb_url lsd "$LATEST"
fi

apt_pkg bat bat
# Ubuntu/Debian ships bat as 'batcat' — add symlink
if has batcat && ! has bat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    green "  bat symlinked from batcat"
fi

apt_pkg ripgrep rg

# fd — packaged as fd-find on Debian/Ubuntu
apt_pkg fd-find fdfind
if has fdfind && ! has fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    green "  fd symlinked from fdfind"
fi

apt_pkg btop

# dust
if ! has dust; then
    LATEST=$(curl -s https://api.github.com/repos/bootandy/dust/releases/latest | grep browser_download_url | grep "x86_64-unknown-linux-musl.tar.gz" | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
    sudo mv "$tmp_dir"/dust-*/dust /usr/local/bin/dust
    rm -rf "$tmp_dir"
fi

# procs
if ! has procs; then
    LATEST=$(curl -s https://api.github.com/repos/dalance/procs/releases/latest | grep browser_download_url | grep "x86_64-linux.zip" | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" -o "$tmp_dir/procs.zip"
    unzip -q "$tmp_dir/procs.zip" -d "$tmp_dir"
    sudo mv "$tmp_dir/procs" /usr/local/bin/procs
    rm -rf "$tmp_dir"
fi

# yazi
if ! has yazi; then
    LATEST=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep browser_download_url | grep "x86_64-unknown-linux-musl.zip" | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" -o "$tmp_dir/yazi.zip"
    unzip -q "$tmp_dir/yazi.zip" -d "$tmp_dir"
    sudo mv "$tmp_dir"/yazi-*/yazi /usr/local/bin/yazi
    rm -rf "$tmp_dir"
fi

# xh
if ! has xh; then
    curl -sfL https://raw.githubusercontent.com/ducaale/xh/master/install.sh | sh
fi

# lazygit
if ! has lazygit; then
    LATEST=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep browser_download_url | grep "Linux_x86_64.tar.gz" | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
    sudo mv "$tmp_dir/lazygit" /usr/local/bin/lazygit
    rm -rf "$tmp_dir"
fi

# gitui
if ! has gitui; then
    LATEST=$(curl -s https://api.github.com/repos/extrawurst/gitui/releases/latest | grep browser_download_url | grep "gitui-linux-x86_64.tar.gz" | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
    sudo mv "$tmp_dir/gitui" /usr/local/bin/gitui
    rm -rf "$tmp_dir"
fi

# bottom (btm)
if ! has btm; then
    LATEST=$(curl -s https://api.github.com/repos/ClementTsang/bottom/releases/latest | grep browser_download_url | grep "x86_64-unknown-linux-musl.tar.gz" | grep -v "full\|debian" | head -1 | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
    sudo mv "$tmp_dir/btm" /usr/local/bin/btm
    rm -rf "$tmp_dir"
fi

# dua
crg dua-cli dua

# skim
crg skim sk

# git-delta
if ! has delta; then
    LATEST=$(curl -s https://api.github.com/repos/dandavison/delta/releases/latest | grep browser_download_url | grep "amd64.deb" | cut -d '"' -f 4)
    deb_url delta "$LATEST"
fi

# hyperfine
if ! has hyperfine; then
    LATEST=$(curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest | grep browser_download_url | grep "amd64.deb" | cut -d '"' -f 4)
    deb_url hyperfine "$LATEST"
fi

# tealdeer (tldr)
if ! has tldr; then
    LATEST=$(curl -s https://api.github.com/repos/dbrgn/tealdeer/releases/latest | grep browser_download_url | grep "tealdeer-linux-x86_64-musl" | grep -v ".sha" | cut -d '"' -f 4)
    sudo curl -fsSL "$LATEST" -o /usr/local/bin/tldr
    sudo chmod +x /usr/local/bin/tldr
fi

# watchexec
if ! has watchexec; then
    LATEST=$(curl -s https://api.github.com/repos/watchexec/watchexec/releases/latest | grep browser_download_url | grep "x86_64-unknown-linux-musl.tar.xz" | head -1 | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" | tar -xJ -C "$tmp_dir"
    sudo mv "$tmp_dir"/watchexec-*/watchexec /usr/local/bin/watchexec
    rm -rf "$tmp_dir"
fi

# topgrade
if ! has topgrade; then
    LATEST=$(curl -s https://api.github.com/repos/topgrade-rs/topgrade/releases/latest | grep browser_download_url | grep "x86_64-unknown-linux-musl.tar.gz" | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
    sudo mv "$tmp_dir/topgrade" /usr/local/bin/topgrade
    rm -rf "$tmp_dir"
fi

# ─── Git tools ───────────────────────────────────────────────────────────────
echo ""
echo "── Git tools ──"

# gh (GitHub CLI)
if ! has gh; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list
    sudo apt-get update -y
    sudo apt-get install -y gh
else
    info "already installed: gh"
fi

# navi
if ! has navi; then
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"
    curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install | BIN_DIR="$BIN_DIR" sh
fi

# ─── Navigation & search ─────────────────────────────────────────────────────
echo ""
echo "── Navigation & search ──"
apt_pkg jq

# yq
if ! has yq; then
    sudo curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" \
        -o /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
fi

# fx
if ! has fx; then
    sudo curl -fsSL "https://github.com/antonmedv/fx/releases/latest/download/fx_linux_amd64" \
        -o /usr/local/bin/fx
    sudo chmod +x /usr/local/bin/fx
fi

# ─── Runtimes ────────────────────────────────────────────────────────────────
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

# Bun
if ! has bun; then
    curl -fsSL https://bun.sh/install | bash
fi

# pyenv
if ! has pyenv; then
    curl https://pyenv.run | bash
fi

# uv
if ! has uv; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# pipx
if ! has pipx; then
    apt_pkg pipx
fi

# mise
if ! has mise; then
    curl https://mise.run | sh
fi

# ─── Productivity ─────────────────────────────────────────────────────────────
echo ""
echo "── Productivity ──"
apt_pkg taskwarrior task
apt_pkg timewarrior timew

# just
if ! has just; then
    curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to "$HOME/.local/bin"
fi

apt_pkg entr

# pet
if ! has pet; then
    LATEST=$(curl -s https://api.github.com/repos/knqyf263/pet/releases/latest | grep browser_download_url | grep "linux_amd64.deb" | cut -d '"' -f 4)
    deb_url pet "$LATEST"
fi

# ─── thefuck ─────────────────────────────────────────────────────────────────
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

# ctop
if ! has ctop; then
    sudo curl -fsSL "https://github.com/bcicen/ctop/releases/latest/download/ctop-linux-amd64" \
        -o /usr/local/bin/ctop
    sudo chmod +x /usr/local/bin/ctop
fi

# lazydocker
if ! has lazydocker; then
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
fi

# ─── TUI tools ───────────────────────────────────────────────────────────────
echo ""
echo "── TUI tools ──"

# macchina
crg macchina

# fastfetch
if ! has fastfetch; then
    LATEST=$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep browser_download_url | grep "linux-amd64.deb" | cut -d '"' -f 4)
    deb_url fastfetch "$LATEST"
fi

# ─── Database ────────────────────────────────────────────────────────────────
echo ""
echo "── Database ──"
if ! has pgcli; then
    pipx install pgcli
fi

# ─── Notes & knowledge ───────────────────────────────────────────────────────
echo ""
echo "── Notes & knowledge ──"
if ! has nb; then
    curl -L https://raw.githubusercontent.com/xwmx/nb/master/nb -o "$HOME/.local/bin/nb"
    chmod +x "$HOME/.local/bin/nb"
fi

if ! has dnote; then
    LATEST=$(curl -s https://api.github.com/repos/dnote/dnote/releases/latest | grep browser_download_url | grep "linux_amd64.tar.gz" | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
    sudo mv "$tmp_dir/dnote" /usr/local/bin/dnote
    rm -rf "$tmp_dir"
fi

# ─── Remote ──────────────────────────────────────────────────────────────────
echo ""
echo "── Remote ──"
apt_pkg mosh
apt_pkg tmate

# ─── Misc utilities ──────────────────────────────────────────────────────────
echo ""
echo "── Misc utilities ──"

# kalker
crg kalker

# atac
if ! has atac; then
    LATEST=$(curl -s https://api.github.com/repos/Julien-cpsn/ATAC/releases/latest | grep browser_download_url | grep "x86_64-unknown-linux-musl.tar.gz" | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
    sudo mv "$tmp_dir/atac" /usr/local/bin/atac
    rm -rf "$tmp_dir"
fi

# posting
if ! has posting; then
    pipx install posting
fi

# gdu
if ! has gdu; then
    curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz \
        | tar xz
    sudo mv gdu_linux_amd64 /usr/local/bin/gdu
fi

# lychee
if ! has lychee; then
    LATEST=$(curl -s https://api.github.com/repos/lycheeverse/lychee/releases/latest | grep browser_download_url | grep "x86_64-unknown-linux-musl.tar.gz" | cut -d '"' -f 4)
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
    sudo mv "$tmp_dir/lychee" /usr/local/bin/lychee
    rm -rf "$tmp_dir"
fi

# mani
if ! has mani; then
    LATEST=$(curl -s https://api.github.com/repos/alajmo/mani/releases/latest | grep browser_download_url | grep "linux_amd64.deb" | cut -d '"' -f 4)
    deb_url mani "$LATEST"
fi

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
