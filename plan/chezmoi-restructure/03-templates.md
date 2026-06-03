# Step 3 — Chezmoi Config Template and File Templates

## Goal

Add `.chezmoi.toml.tmpl` so chezmoi prompts for machine-specific values on first
`chezmoi init`. Convert hardcoded values in dotfiles to template variables.
Remove all references to `/home/labor-client18/` and hardcoded machine-specific
paths from the committed files.

---

## 3.1 Create `.chezmoi.toml.tmpl`

This file lives at the root of the chezmoi source dir. It runs once during
`chezmoi init` and generates `~/.config/chezmoi/chezmoi.toml` on the target
machine. It is committed to the repo and safe to be public.

```toml
{{- $name    := promptStringOnce . "name"    "Full name" -}}
{{- $email   := promptStringOnce . "email"   "Email address" -}}
{{- $machine := promptChoiceOnce . "machine" "Machine type"
      (list "archwsl" "arch" "ubuntu" "mac" "nixos" "server") -}}
{{- $wsl     := promptBoolOnce   . "wsl"     "Running inside WSL2" -}}
{{- $work    := promptBoolOnce   . "work"    "Work machine" -}}

[chezmoi]
    sourceDir = "{{ .chezmoi.homeDir }}/.local/share/chezmoi"

[data]
    name    = {{ $name    | quote }}
    email   = {{ $email   | quote }}
    machine = {{ $machine | quote }}
    wsl     = {{ $wsl }}
    work    = {{ $work }}
```

`promptStringOnce` / `promptBoolOnce` / `promptChoiceOnce` only prompt on the
first run — subsequent `chezmoi apply` calls reuse the stored values in
`chezmoi.toml`. The user never gets asked again on the same machine.

These values are accessible in all `.tmpl` files as:
- `{{ .chezmoidata.name }}`
- `{{ .chezmoidata.email }}`
- `{{ .chezmoidata.machine }}`
- `{{ .chezmoidata.wsl }}`
- `{{ .chezmoidata.work }}`

And chezmoi built-ins:
- `{{ .chezmoi.os }}` — `linux`, `darwin`, `windows`
- `{{ .chezmoi.arch }}` — `amd64`, `arm64`
- `{{ .chezmoi.hostname }}`
- `{{ .chezmoi.homeDir }}` — replaces all `~` and `/home/username` hardcoding

---

## 3.2 Convert `dot_gitconfig.tmpl`

Before (hardcoded):
```ini
[user]
    name  = Thien-An Ngo
    email = thienan.tianen@gmail.com
```

After (templated):
```ini
[user]
    name  = {{ .chezmoidata.name }}
    email = {{ .chezmoidata.email }}

{{- if .chezmoidata.work }}
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig.work
{{- end }}
```

---

## 3.3 Convert `dot_zshrc.tmpl`

This is the most involved template. Work through it section by section.

### Username/path hardcoding

Every occurrence of `/home/labor-client18` becomes `{{ .chezmoi.homeDir }}`.

Before:
```sh
export PATH="$PATH:/home/labor-client18/.local/bin"
export PATH="/home/labor-client18/.lando/bin:$PATH"
export devteam="/home/labor-client18/workspace/dev_team.sh"
source "/home/labor-client18/.openclaw/completions/openclaw.zsh"
[ -s "/home/labor-client18/.bun/_bun" ] && source "/home/labor-client18/.bun/_bun"
```

After:
```sh
export PATH="$PATH:{{ .chezmoi.homeDir }}/.local/bin"
export PATH="{{ .chezmoi.homeDir }}/.lando/bin:$PATH"
export devteam="{{ .chezmoi.homeDir }}/workspace/dev_team.sh"
[ -f "{{ .chezmoi.homeDir }}/.openclaw/completions/openclaw.zsh" ] && \
  source "{{ .chezmoi.homeDir }}/.openclaw/completions/openclaw.zsh"
[ -s "{{ .chezmoi.homeDir }}/.bun/_bun" ] && \
  source "{{ .chezmoi.homeDir }}/.bun/_bun"
```

### WSL-only sections

Gate anything that only makes sense inside WSL2:

```sh
{{- if .chezmoidata.wsl }}
# WSL clipboard
alias pbcopy='clip.exe'
alias pbpaste='powershell.exe -command Get-Clipboard'

fclip() { cat "$1" | clip.exe; }

agy() {
  local AG_EXE="{{ .chezmoi.homeDir }}/AppData/Local/Programs/Antigravity/bin/antigravity"
  "$AG_EXE" --remote wsl+"$WSL_DISTRO_NAME" "$(readlink -f "${1:-.}")"
}

export PATH="$PATH:/mnt/c/Users/Labor-Client18/AppData/Local/Programs/cursor/resources/app/bin"
export PATH="$PATH:/opt/mssql-tools18/bin"
{{- end }}
```

### Work-machine-only sections

```sh
{{- if .chezmoidata.work }}
export PATH="{{ .chezmoi.homeDir }}/.lando/bin:$PATH"
export devteam="{{ .chezmoi.homeDir }}/workspace/dev_team.sh"
source "{{ .chezmoi.homeDir }}/.openclaw/completions/openclaw.zsh"
{{- end }}
```

### OS-specific sections

```sh
{{- if eq .chezmoi.os "darwin" }}
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- end }}
```

### thefuck init — guard for venv location

```sh
{{- if eq .chezmoidata.machine "archwsl" | or (eq .chezmoidata.machine "arch") }}
eval "$({{ .chezmoi.homeDir }}/.thefuck-env/bin/thefuck --alias fuck)"
{{- else }}
command -v thefuck &>/dev/null && eval "$(thefuck --alias fuck)"
{{- end }}
```

---

## 3.4 Convert `dot_zshenv.tmpl`

Current content after the cargo fix:
```sh
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
```

This is already clean. Rename to `dot_zshenv` (no `.tmpl`) unless machine-specific
values are needed here. Currently none are required.

If pyenv root needs to vary by machine it can be templated:
```sh
export PYENV_ROOT="{{ .chezmoi.homeDir }}/.pyenv"
```
But `$HOME` works fine at runtime so this is optional.

---

## 3.5 What Does NOT Need Templating

- `dot_zprofile` — no hardcoded values
- `dot_tmux.conf` — no hardcoded values (tmux yank to `clip.exe` should be
  gated on WSL; handle this here or in step when WSL todo is addressed)
- `dot_config/starship.toml` — fully portable
- `dot_config/btop/` — portable
- `dot_config/micro/` — portable
- `dot_claude/settings.json` — portable

---

## 3.6 Testing Templates

Preview what chezmoi will write without applying:
```sh
chezmoi execute-template < ~/.local/share/chezmoi/dot_zshrc.tmpl
```

Diff the templated output against the current live file:
```sh
chezmoi diff ~/.zshrc
```

Apply and verify shell loads correctly:
```sh
chezmoi apply ~/.zshrc ~/.zshenv ~/.gitconfig
exec zsh
```

---

## Verification Checklist

- [ ] `.chezmoi.toml.tmpl` committed and prompts work on `chezmoi init` test
- [ ] `chezmoi data` shows all expected values
- [ ] `~/.gitconfig` no longer has hardcoded name/email in source
- [ ] `~/.zshrc` no longer has `/home/labor-client18` in source
- [ ] `chezmoi diff` shows no unexpected changes after apply
- [ ] Shell loads without errors on clean `exec zsh`
- [ ] Non-WSL machine would not get `clip.exe` aliases (verify via `chezmoi execute-template`)

## Next Step

→ `04-externals.md`
