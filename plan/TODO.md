# Dotfiles TODO

## Shelved

- [ ] **Interactive bootstrap script** (`bootstrap.sh`)
  Curl-able entry point for clean installs. Handles pre-chezmoi setup:
  SSH keygen → copy pubkey to clipboard → prompt user to add to GitHub →
  loop `ssh -T git@github.com` until confirmed → install chezmoi →
  `chezmoi init --apply github.com/thien-an-ngo/dotfiles`.
  Designed to be the very first thing run on a fresh machine before anything else exists.
  See `plan/bootstrap/` when started.

---

## Pending

- [ ] **Standalone Linux compatibility (non-WSL)**
  The current dotfiles assume WSL2 throughout — `clip.exe`, Windows paths in `$PATH`,
  `agy()` WSL function, `$WSL_DISTRO_NAME`, `clip.exe` for tmux yank, etc.
  Need chezmoi template conditionals so the same repo works cleanly on bare Linux
  (desktop or laptop) without WSL-specific lines appearing or erroring.
  Affects: `dot_zshrc.tmpl`, `dot_tmux.conf`, `dot_gitconfig.tmpl`.
  Gate on `{{ .chezmoidata.wsl }}` boolean set during `chezmoi init` prompts.

- [ ] **Lightweight server install profile**
  A minimal install for headless/server machines where the full stack is unwanted.
  Stack: `zsh` + `starship` + `tmux` only. No zoxide, no atuin, no lsd, no heavy TUI tools.
  Should work via:
  - A `--profile server` flag on each system installer (`arch/install.sh`, `apt/install.sh`, etc.)
  - A matching `dot_zshrc_server.tmpl` (or a `server` branch inside the main template)
    that strips aliases, plugin loading, and tool inits down to bare minimum
  - A separate `dot_tmux_server.conf` or template flag stripping TPM and heavy plugins
  - Should be usable standalone without the full chezmoi setup (single-script curl install)
  Consider: does the lightweight profile belong inside chezmoi or as a fully separate
  `server/install.sh` + `server/zshrc` that has zero dependency on the rest of this repo?
