# Step 7 — Windows Native Support

## Goal

Make the same dotfiles repo work natively on Windows (outside WSL) via chezmoi,
PowerShell 7, Scoop, and winget. The repo stays a single source of truth — OS
branching is handled entirely by chezmoi templates and the `windows/install.ps1`
installer.

---

## Architecture

```
chezmoi apply (Windows)
    │
    ├── dot_zshrc.tmpl           → skipped (not a valid Windows path target)
    ├── windows/
    │   └── Microsoft.PowerShell_profile.ps1.tmpl  → ~\Documents\PowerShell\Profile.ps1
    ├── dot_config/starship.toml → %APPDATA%\...\starship.toml  (chezmoi maps correctly)
    └── run_once_install.sh.tmpl → calls windows/install.ps1
```

Chezmoi on Windows maps `~` to `%USERPROFILE%` and handles path separators.
Most `dot_config/` entries work without changes. Shell-specific files
(`.zshrc`, `.tmux.conf`) are skipped on Windows via template conditionals.

---

## 7.1 Gate Unix-Only Files

Wrap Unix-only dotfiles with OS conditionals. In `.chezmoi.toml.tmpl`, chezmoi
automatically skips files whose template renders to empty — use this:

For `dot_zshrc.tmpl`, `dot_zprofile`, `dot_tmux.conf` — add at the very top:

```
{{- if ne .chezmoi.os "windows" -}}
... entire file content ...
{{- end -}}
```

Chezmoi will not write the file on Windows if the output is empty.

Alternatively use `.chezmoiignore` with a template:
```
{{- if eq .chezmoi.os "windows" }}
dot_zshrc.tmpl
dot_zprofile
dot_tmux.conf
dot_zshenv.tmpl
{{- end }}
```

---

## 7.2 PowerShell Profile Template

`windows/Microsoft.PowerShell_profile.ps1.tmpl` is the Windows equivalent of `.zshrc`.

Chezmoi on Windows cannot write to the arbitrary path
`~\Documents\PowerShell\Profile.ps1` directly via `dot_` naming. Use a
`run_once_` script to symlink or copy it instead:

```powershell
# run_once_windows-profile.ps1.tmpl (only runs on Windows)
{{- if ne .chezmoi.os "windows" }}{{ exit }}{{- end }}

$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory $profileDir }

$src = "{{ .chezmoi.sourceDir }}\windows\Microsoft.PowerShell_profile.ps1"
Copy-Item $src $PROFILE -Force
```

The profile itself covers:
- Oh My Posh init (replacement for starship on PowerShell, or starship directly)
- Scoop PATH setup
- Aliases mirroring the Unix aliases (lsd, bat, rg, fd, etc.)
- PSReadLine config (fzf-tab equivalent via PSFzf)
- Zoxide init (`Invoke-Expression (& { (zoxide init powershell | Out-String) })`)
- NVM-Windows or Volta init
- Equivalent of the WSL `agy()` function if needed

---

## 7.3 Scoop + Winget Installer

`windows/install.ps1` mirrors the structure of `arch/install.sh`:

```powershell
param([string]$Categories = "core,cli,shell")

function Has { param($cmd) return [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function HasCategory { param($cat) return $Categories -split "," -contains $cat }

# Ensure Scoop
if (-not (Has "scoop")) {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
}

# Add Scoop buckets
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add versions

# Core
if (HasCategory "core") {
    # git comes with Scoop bootstrap but ensure it
    scoop install git
    scoop install neovim
    scoop install starship
    scoop install fzf
    # zoxide
    scoop install zoxide
}

# CLI
if (HasCategory "cli") {
    scoop install lsd
    scoop install bat
    scoop install ripgrep
    scoop install fd
    scoop install btop
    scoop install dust
    scoop install delta
    scoop install hyperfine
    scoop install tealdeer
    scoop install watchexec
    scoop install topgrade
}

# Shell
if (HasCategory "shell") {
    scoop install atuin
    scoop install navi
    # thefuck: pip install thefuck (needs Python)
}

# TUI
if (HasCategory "tui") {
    scoop install lazygit
    scoop install extras/gitui
    scoop install yazi
    scoop install fastfetch
}

# Runtimes
if (HasCategory "runtimes") {
    # Node via nvm-windows
    scoop install nvm
    nvm install lts
    nvm use lts
    # Bun
    scoop install bun
    # Rust
    scoop install rustup
    rustup install stable
    # uv, mise
    scoop install uv
    scoop install mise
}

# Git tools
if (HasCategory "core") {
    scoop install gh
    scoop install lazygit
}

# Utils
if (HasCategory "utils") {
    scoop install jq
    scoop install yq
    scoop install gdu
}

# winget for GUI apps (not relevant to dotfiles tools but here for completeness)
# winget install Microsoft.WindowsTerminal
# winget install Microsoft.PowerShell
```

---

## 7.4 Starship on Windows

Starship works natively on Windows with no changes needed to `starship.toml`.
The `dot_config/starship.toml` path on Windows maps correctly.

Add to PowerShell profile:
```powershell
Invoke-Expression (&starship init powershell)
```

---

## 7.5 Tools That Don't Translate

| Unix tool | Windows situation |
|---|---|
| `tmux` | Not available natively. Windows Terminal handles tabs/panes. Skip on Windows. |
| `thefuck` | Works via pip on Windows with PowerShell. Install in runtimes category. |
| `atuin` | Windows support is experimental as of 2026. Check current status before including. |
| `clip.exe` | Built-in on Windows — the WSL clipboard aliases become no-ops. |
| `mosh` | No native Windows binary. Skip. |
| `procs` | Works on Windows. Scoop: `scoop install procs`. |
| `yazi` | Works on Windows. Scoop extras: `scoop install yazi`. |
| `zoxide` | Works on Windows. Scoop: `scoop install zoxide`. |

---

## 7.6 WSL Integration from Windows Side

`windows/install.ps1` can optionally bootstrap WSL2 and point it at this same
dotfiles repo, completing the loop:

```powershell
# Optional: install ArchWSL
if (-not (wsl -l -q 2>$null | Select-String "Arch")) {
    winget install --id=Jugal.ArchWSL
}

# After ArchWSL is set up, the user runs bootstrap.sh inside it
# (This is the shelved bootstrap.sh task)
Write-Host "WSL installed. Inside Arch, run:"
Write-Host "  sh -c `"`$(curl -fsLS get.chezmoi.io)`" -- init --apply github.com/thien-an-ngo/dotfiles"
```

---

## Verification Checklist

- [ ] `chezmoi apply` on Windows skips Unix-only files (zshrc, tmux, zprofile)
- [ ] PowerShell profile written correctly by `run_once_windows-profile.ps1.tmpl`
- [ ] `windows/install.ps1` accepts `--categories` (or `-Categories`) and installs correctly
- [ ] Starship prompt works in PowerShell
- [ ] Zoxide works in PowerShell (`cd` → `z` equivalent)
- [ ] `chezmoi update` on Windows pulls and applies changes without errors
- [ ] `dot_config/starship.toml` and other portable configs apply correctly
