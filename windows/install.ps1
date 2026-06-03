# windows/install.ps1 — install tools on Windows via Scoop (+ winget fallback)
# Usage: powershell -ExecutionPolicy Bypass -File windows\install.ps1 [-Categories "core,cli,shell"]

param(
    [string]$Categories = "core,cli,shell,tui,runtimes,productivity,remote,db,utils"
)

function has_cat([string]$cat) {
    return (",$Categories," -like "*,$cat,*")
}

function has_cmd([string]$cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

function scoop_install([string]$pkg, [string]$bin = "") {
    if ($bin -eq "") { $bin = $pkg }
    if (has_cmd $bin) {
        Write-Host "  already installed: $bin"
    } else {
        Write-Host "  [scoop] $pkg"
        scoop install $pkg
    }
}

function winget_install([string]$id, [string]$bin = "") {
    if ($bin -eq "") { $bin = $id }
    if (has_cmd $bin) {
        Write-Host "  already installed: $bin"
    } else {
        Write-Host "  [winget] $id"
        winget install --id $id --silent --accept-package-agreements --accept-source-agreements
    }
}

# ─── Bootstrap Scoop (always runs) ───────────────────────────────────────────
if (-not (has_cmd scoop)) {
    Write-Host ""
    Write-Host "── Installing Scoop ──"
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    Write-Host "  Scoop installed"
}

# Add buckets
Write-Host ""
Write-Host "── Scoop buckets ──"
foreach ($bucket in @("extras", "nerd-fonts", "versions")) {
    if (-not (scoop bucket list | Select-String $bucket)) {
        scoop bucket add $bucket
    }
}

# System update
scoop update
scoop update *

# ─── core ────────────────────────────────────────────────────────────────────
if (has_cat "core") {
    Write-Host ""
    Write-Host "── Core tools ──"
    scoop_install git
    scoop_install neovim nvim
    scoop_install starship
    scoop_install fzf
    scoop_install gh
    scoop_install chezmoi
    scoop_install unzip
    scoop_install curl
    scoop_install wget
}

# ─── cli ─────────────────────────────────────────────────────────────────────
if (has_cat "cli") {
    Write-Host ""
    Write-Host "── Modern CLI replacements ──"
    scoop_install lsd
    scoop_install bat
    scoop_install ripgrep rg
    scoop_install fd
    scoop_install btop
    scoop_install delta
    scoop_install hyperfine
    scoop_install tealdeer tldr
    scoop_install watchexec
    scoop_install topgrade
    scoop_install dua
    scoop_install bottom btm
    scoop_install xh
    scoop_install jq
    scoop_install yq
}

# ─── shell ────────────────────────────────────────────────────────────────────
if (has_cat "shell") {
    Write-Host ""
    Write-Host "── Shell enhancements ──"
    scoop_install zoxide
    scoop_install atuin
    scoop_install navi
}

# ─── tui ─────────────────────────────────────────────────────────────────────
if (has_cat "tui") {
    Write-Host ""
    Write-Host "── TUI tools ──"
    scoop_install yazi
    scoop_install gitui
    scoop_install lazydocker
    scoop_install fastfetch
    scoop_install lazygit
}

# ─── runtimes ────────────────────────────────────────────────────────────────
if (has_cat "runtimes") {
    Write-Host ""
    Write-Host "── Runtimes ──"
    scoop_install nvm
    scoop_install bun
    scoop_install rustup
    scoop_install uv
    scoop_install mise
    # Python via scoop
    if (-not (has_cmd python)) {
        scoop install python
    }
    # Node LTS via nvm
    if (has_cmd nvm) {
        nvm install lts
        nvm use lts
    }
}

# ─── productivity ─────────────────────────────────────────────────────────────
if (has_cat "productivity") {
    Write-Host ""
    Write-Host "── Productivity ──"
    scoop_install just
    scoop_install entr
}

# ─── db ──────────────────────────────────────────────────────────────────────
if (has_cat "db") {
    Write-Host ""
    Write-Host "── Database ──"
    # pgcli via pip (winget fallback for Python if needed)
    if (has_cmd pip) {
        if (-not (has_cmd pgcli)) {
            pip install pgcli
        }
    } else {
        Write-Host "  skipping pgcli — Python/pip not available"
    }
}

# ─── utils ───────────────────────────────────────────────────────────────────
if (has_cat "utils") {
    Write-Host ""
    Write-Host "── Misc utilities ──"
    scoop_install gdu
    scoop_install fd
    scoop_install jq
    scoop_install yq
}

# ─── Summary ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════"
Write-Host "Done! Packages installed (categories: $Categories)"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart your terminal"
Write-Host "  2. Run:  atuin login   (optional — sync shell history)"
Write-Host "  3. Run:  gh auth login (optional — GitHub CLI auth)"
Write-Host ""
