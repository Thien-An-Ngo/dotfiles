#!/usr/bin/env bash
# apt/install.sh — install tools used by this dotfiles repo on Debian/Ubuntu
# Idempotent: skips anything already installed. Run as a normal user (sudo will be prompted).
# Usage: bash apt/install.sh [--categories core,cli,shell,...]

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

# ─── Helpers ─────────────────────────────────────────────────────────────────
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

gh_latest() {
    # gh_latest <owner/repo> <grep-pattern> → prints download URL
    curl -s "https://api.github.com/repos/$1/releases/latest" \
        | grep browser_download_url | grep "$2" | head -1 | cut -d '"' -f 4
}

# ─── System update (always runs) ─────────────────────────────────────────────
echo ""
echo "── System update ──"
sudo apt-get update -y
sudo apt-get upgrade -y

# ─── core ────────────────────────────────────────────────────────────────────
if has_cat core; then
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
    apt_pkg tmux
    apt_pkg fzf

    # starship
    if ! has starship; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # neovim
    if ! has nvim; then
        if grep -qi ubuntu /etc/os-release 2>/dev/null; then
            sudo add-apt-repository ppa:neovim-ppa/stable -y
            sudo apt-get update -y
            sudo apt-get install -y neovim
        else
            curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
                | sudo tar -xz -C /opt
            sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
        fi
        green "  nvim installed"
    else
        info "already installed: nvim"
    fi

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

    # chezmoi
    if ! has chezmoi; then
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    fi

    # Zsh default shell
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
fi

# ─── cli ─────────────────────────────────────────────────────────────────────
if has_cat cli; then
    echo ""
    echo "── Modern CLI replacements ──"

    # lsd
    if ! has lsd; then
        LATEST=$(gh_latest lsd-rs/lsd "amd64.deb")
        deb_url lsd "$LATEST"
    fi

    apt_pkg bat bat
    if has batcat && ! has bat; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        green "  bat symlinked from batcat"
    fi

    apt_pkg ripgrep rg

    apt_pkg fd-find fdfind
    if has fdfind && ! has fd; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
        green "  fd symlinked from fdfind"
    fi

    apt_pkg btop

    # dust
    if ! has dust; then
        LATEST=$(gh_latest bootandy/dust "x86_64-unknown-linux-musl.tar.gz")
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
        sudo mv "$tmp_dir"/dust-*/dust /usr/local/bin/dust
        rm -rf "$tmp_dir"
    fi

    # procs
    if ! has procs; then
        LATEST=$(gh_latest dalance/procs "x86_64-linux.zip")
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" -o "$tmp_dir/procs.zip"
        unzip -q "$tmp_dir/procs.zip" -d "$tmp_dir"
        sudo mv "$tmp_dir/procs" /usr/local/bin/procs
        rm -rf "$tmp_dir"
    fi

    # git-delta
    if ! has delta; then
        LATEST=$(gh_latest dandavison/delta "amd64.deb")
        deb_url delta "$LATEST"
    fi

    # hyperfine
    if ! has hyperfine; then
        LATEST=$(gh_latest sharkdp/hyperfine "amd64.deb")
        deb_url hyperfine "$LATEST"
    fi

    # tealdeer (tldr)
    if ! has tldr; then
        LATEST=$(gh_latest dbrgn/tealdeer "tealdeer-linux-x86_64-musl" | grep -v ".sha")
        sudo curl -fsSL "$LATEST" -o /usr/local/bin/tldr
        sudo chmod +x /usr/local/bin/tldr
    fi

    # watchexec
    if ! has watchexec; then
        LATEST=$(gh_latest watchexec/watchexec "x86_64-unknown-linux-musl.tar.xz")
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" | tar -xJ -C "$tmp_dir"
        sudo mv "$tmp_dir"/watchexec-*/watchexec /usr/local/bin/watchexec
        rm -rf "$tmp_dir"
    fi

    # topgrade
    if ! has topgrade; then
        LATEST=$(gh_latest topgrade-rs/topgrade "x86_64-unknown-linux-musl.tar.gz")
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
        sudo mv "$tmp_dir/topgrade" /usr/local/bin/topgrade
        rm -rf "$tmp_dir"
    fi

    # dua
    crg dua-cli dua

    # bottom (btm)
    if ! has btm; then
        LATEST=$(gh_latest ClementTsang/bottom "x86_64-unknown-linux-musl.tar.gz" | grep -v "full\|debian" | head -1)
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
        sudo mv "$tmp_dir/btm" /usr/local/bin/btm
        rm -rf "$tmp_dir"
    fi

    # xh
    if ! has xh; then
        curl -sfL https://raw.githubusercontent.com/ducaale/xh/master/install.sh | sh
    fi

    # skim
    crg skim sk

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
fi

# ─── shell ────────────────────────────────────────────────────────────────────
if has_cat shell; then
    echo ""
    echo "── Shell enhancements ──"

    # zoxide
    if ! has zoxide; then
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # atuin
    if ! has atuin; then
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
    fi

    # navi
    if ! has navi; then
        BIN_DIR="$HOME/.local/bin"
        mkdir -p "$BIN_DIR"
        curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install | BIN_DIR="$BIN_DIR" sh
    fi

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

    # yazi
    if ! has yazi; then
        LATEST=$(gh_latest sxyazi/yazi "x86_64-unknown-linux-musl.zip")
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" -o "$tmp_dir/yazi.zip"
        unzip -q "$tmp_dir/yazi.zip" -d "$tmp_dir"
        sudo mv "$tmp_dir"/yazi-*/yazi /usr/local/bin/yazi
        rm -rf "$tmp_dir"
    fi

    # gitui
    if ! has gitui; then
        LATEST=$(gh_latest extrawurst/gitui "gitui-linux-x86_64.tar.gz")
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
        sudo mv "$tmp_dir/gitui" /usr/local/bin/gitui
        rm -rf "$tmp_dir"
    fi

    # lazydocker
    if ! has lazydocker; then
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    fi

    # macchina
    crg macchina

    # fastfetch
    if ! has fastfetch; then
        LATEST=$(gh_latest fastfetch-cli/fastfetch "linux-amd64.deb")
        deb_url fastfetch "$LATEST"
    fi

    # lazygit
    if ! has lazygit; then
        LATEST=$(gh_latest jesseduffield/lazygit "Linux_x86_64.tar.gz")
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
        sudo mv "$tmp_dir/lazygit" /usr/local/bin/lazygit
        rm -rf "$tmp_dir"
    fi
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
fi

# ─── productivity ─────────────────────────────────────────────────────────────
if has_cat productivity; then
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
        LATEST=$(gh_latest knqyf263/pet "linux_amd64.deb")
        deb_url pet "$LATEST"
    fi
fi

# ─── remote ──────────────────────────────────────────────────────────────────
if has_cat remote; then
    echo ""
    echo "── Remote ──"
    apt_pkg mosh
    apt_pkg tmate
fi

# ─── db ──────────────────────────────────────────────────────────────────────
if has_cat db; then
    echo ""
    echo "── Database ──"
    if ! has pgcli; then
        pipx install pgcli
    fi
fi

# ─── utils ───────────────────────────────────────────────────────────────────
if has_cat utils; then
    echo ""
    echo "── Misc utilities ──"

    # kalker
    crg kalker

    # atac
    if ! has atac; then
        LATEST=$(gh_latest Julien-cpsn/ATAC "x86_64-unknown-linux-musl.tar.gz")
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
        LATEST=$(gh_latest lycheeverse/lychee "x86_64-unknown-linux-musl.tar.gz")
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
        sudo mv "$tmp_dir/lychee" /usr/local/bin/lychee
        rm -rf "$tmp_dir"
    fi

    # mani
    if ! has mani; then
        LATEST=$(gh_latest alajmo/mani "linux_amd64.deb")
        deb_url mani "$LATEST"
    fi

    # nb
    if ! has nb; then
        curl -L https://raw.githubusercontent.com/xwmx/nb/master/nb -o "$HOME/.local/bin/nb"
        chmod +x "$HOME/.local/bin/nb"
    fi

    # dnote
    if ! has dnote; then
        LATEST=$(gh_latest dnote/dnote "linux_amd64.tar.gz")
        tmp_dir=$(mktemp -d)
        curl -fsSL "$LATEST" | tar -xz -C "$tmp_dir"
        sudo mv "$tmp_dir/dnote" /usr/local/bin/dnote
        rm -rf "$tmp_dir"
    fi
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
