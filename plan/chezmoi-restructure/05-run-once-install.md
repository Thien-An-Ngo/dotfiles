# Step 5 — Convert Install Scripts to `run_once_install.sh.tmpl`

## Goal

Replace the manual `bash arch/install.sh` workflow with a chezmoi-managed
`run_once_install.sh.tmpl` that auto-detects the OS and calls the right installer.
After this step, `install.sh` at the repo root is deleted — it is fully superseded.

---

## How `run_once_` Works

Chezmoi tracks a SHA256 of every `run_once_` script in `~/.local/share/chezmoi/.chezmoi-run-state.boltdb`.

- First `chezmoi apply` on a new machine: script has never run → runs it.
- Subsequent `chezmoi apply` with unchanged script: already ran → skips.
- Script content changes (e.g. new package added): hash differs → runs again.

This means adding a package to `arch/install.sh` and committing it will cause
the install script to re-run on next `chezmoi apply` on all machines — which is
correct since `arch/install.sh` is idempotent (all tools check `has()` before installing).

---

## 5.1 Create `run_once_install.sh.tmpl`

```sh
#!/usr/bin/env bash
# chezmoi:template:left-delimiter="{{" right-delimiter="}}"
# Runs once per machine (re-runs if this file changes).

set -euo pipefail

DOTFILES="{{ .chezmoi.sourceDir }}"

# Resolve categories from chezmoi data or fall back to core+cli+shell
CATEGORIES="{{ .chezmoidata.categories | default "core,cli,shell" }}"

{{- if eq .chezmoidata.machine "server" }}
# Server profile: bypass interactive installer, install minimal set only
CATEGORIES="core"
{{- end }}

echo ""
echo "═══════════════════════════════════════════════"
echo " Installing packages for: {{ .chezmoidata.machine }}"
echo " Categories: $CATEGORIES"
echo "═══════════════════════════════════════════════"

{{- if eq .chezmoi.os "linux" }}
  {{- $id     := .chezmoi.osRelease.id     | default "" }}
  {{- $idLike := .chezmoi.osRelease.idLike | default "" }}

  {{- if or (eq $id "arch") (contains "arch" $idLike) }}
bash "$DOTFILES/arch/install.sh" --categories "$CATEGORIES"

  {{- else if or (eq $id "ubuntu") (eq $id "debian") (contains "debian" $idLike) }}
bash "$DOTFILES/apt/install.sh" --categories "$CATEGORIES"

  {{- else if eq $id "nixos" }}
echo "NixOS detected — run nixos-rebuild switch manually."
echo "See $DOTFILES/nixos/configuration.nix"

  {{- else }}
echo "Unknown Linux distro: {{ .chezmoi.osRelease.id }}"
echo "Run the appropriate installer from $DOTFILES manually."
  {{- end }}

{{- else if eq .chezmoi.os "darwin" }}
bash "$DOTFILES/brew/install.sh" --categories "$CATEGORIES"

{{- else if eq .chezmoi.os "windows" }}
powershell -ExecutionPolicy Bypass -File "$DOTFILES/windows/install.ps1" -Categories "$CATEGORIES"

{{- else }}
echo "Unsupported OS: {{ .chezmoi.os }}"
{{- end }}
```

---

## 5.2 Add `categories` to `.chezmoi.toml.tmpl`

Add a prompt for which categories to install. Add to the existing template:

```toml
{{- $categories := promptStringOnce . "categories"
      "Package categories to install (comma-separated: core,cli,shell,tui,runtimes,productivity,remote,db,utils)"
      | default "core,cli,shell" -}}

[data]
    ...
    categories = {{ $categories | quote }}
```

On the interactive installer path (step described in TODO), this gets overridden
by `scripts/interactive.sh` output before `chezmoi apply` is run.

---

## 5.3 Add `--categories` Flag to System Installers

Each system installer (`arch/install.sh`, `apt/install.sh`, etc.) needs to accept
and respect a `--categories` flag. Refactor each to:

```sh
# Parse --categories flag
CATEGORIES="core"
while [[ $# -gt 0 ]]; do
    case $1 in
        --categories) CATEGORIES="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Helper: check if a category is requested
has_category() { echo "$CATEGORIES" | grep -qw "$1"; }

# Usage:
if has_category core; then
    pac zsh
    pac git
    pac tmux
    pac starship
    pac fzf
    pac neovim nvim
fi

if has_category cli; then
    pac lsd
    pac bat
    pac ripgrep rg
    pac fd
    pac btop
    pac git-delta delta
    # ...
fi

if has_category shell; then
    pac atuin
    pac zoxide
    pac navi
    # thefuck venv install
fi

if has_category tui; then
    aur yazi-bin yazi
    aur gitui
    aur lazydocker-bin lazydocker
    aur fastfetch-bin fastfetch
    # ...
fi

if has_category runtimes; then
    # rust, nvm, bun, pyenv, uv, mise
fi

if has_category productivity; then
    aur taskwarrior task
    aur timewarrior timew
    aur just
    pac entr
fi

if has_category remote; then
    pac mosh
    aur tmate
fi

if has_category db; then
    aur pgcli
fi

if has_category utils; then
    pac jq
    aur yq-go yq
    pac navi
    pac kalker
    # ...
fi
```

The `server` profile maps to `--categories core` only (zsh, git, tmux, starship, fzf).
See TODO for the full server profile plan.

---

## 5.4 Interactive Path

For machines where you want to choose categories manually before install:

```sh
# Before chezmoi apply, run the picker and export the result
export CHEZMOI_CATEGORIES=$(bash ~/.local/share/chezmoi/scripts/interactive.sh)

# Then apply — the run_once script reads CHEZMOI_CATEGORIES
# (Requires: pass env var into the template OR write it to chezmoi.toml first)
```

The cleanest approach: `scripts/interactive.sh` writes the chosen categories
directly to `~/.config/chezmoi/chezmoi.toml` under `[data] categories = ...`,
then calls `chezmoi apply`. This way the choice is persisted and used by the
`run_once_` template.

```sh
# scripts/interactive.sh (excerpt)
SELECTED=$(printf '%s\n' core cli shell tui runtimes productivity remote db utils \
    | fzf --multi --prompt="Select categories > " | paste -sd,)

# Write to chezmoi config
chezmoi config set data.categories "$SELECTED"

# Trigger install
chezmoi apply
```

---

## 5.5 Delete `install.sh`

After this step, the root `install.sh` is fully superseded:
- Symlinking → chezmoi apply
- Git clone (OMZ, TPM, plugins) → `.chezmoiexternal.toml`
- Tool checks → `scripts/checks.sh` (called standalone)
- Tool installation → `run_once_install.sh.tmpl` → system installer

```sh
git rm install.sh
git commit -m "chore: remove install.sh — superseded by chezmoi"
```

Update `CLAUDE.md` to remove references to `install.sh`.

---

## Verification Checklist

- [ ] `run_once_install.sh.tmpl` committed and OS detection tested with `chezmoi execute-template`
- [ ] `arch/install.sh` accepts `--categories` flag and correctly gates installs
- [ ] `apt/install.sh` same
- [ ] `brew/install.sh` same
- [ ] `chezmoi apply` on a fresh clone triggers the install script once
- [ ] `chezmoi apply` on the same machine a second time does NOT re-trigger
- [ ] Changing a package in `arch/install.sh` and committing causes re-trigger on next apply
- [ ] `install.sh` deleted and `CLAUDE.md` updated

## Next Step

→ `06-secrets.md`
