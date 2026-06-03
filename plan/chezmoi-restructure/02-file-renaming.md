# Step 2 — Rename Files to Chezmoi Conventions

## Goal

Rename all source files to chezmoi's naming convention so chezmoi fully manages
them. Do this in batches, verifying after each batch that the live machine is
still intact and `chezmoi apply` produces no unintended changes.

## Chezmoi Naming Reference

| Prefix/suffix | Meaning |
|---|---|
| `dot_` | maps to `.` in target (e.g. `dot_zshrc` → `~/.zshrc`) |
| `private_` | target gets mode 600 |
| `executable_` | target gets chmod +x |
| `.tmpl` suffix | file is a Go template, processed before writing |
| `exact_` | directory: removes target files not in source |
| `dot_config/` | maps to `~/.config/` |

---

## Current Structure → Target Structure

### Home dotfiles (`home/` → repo root)

| Current path | Chezmoi source name | Target |
|---|---|---|
| `home/.zshrc` | `dot_zshrc.tmpl` | `~/.zshrc` |
| `home/.zshenv` | `dot_zshenv.tmpl` | `~/.zshenv` |
| `home/.zprofile` | `dot_zprofile` | `~/.zprofile` |
| `home/.tmux.conf` | `dot_tmux.conf` | `~/.tmux.conf` |
| `home/.gitconfig` | `dot_gitconfig.tmpl` | `~/.gitconfig` |

Note: `.zshrc`, `.zshenv`, `.gitconfig` get `.tmpl` because they contain
hardcoded values (paths, identity) that will be templated in step 3.
`.zprofile` and `.tmux.conf` are static — no `.tmpl` needed unless
WSL conditionals are added later.

### Claude settings

| Current path | Chezmoi source name | Target |
|---|---|---|
| `claude/settings.json` | `dot_claude/settings.json` | `~/.claude/settings.json` |

### Config directory entries (`~/.config/*`)

These currently live at `~/.config/<name>` directly (since the repo IS `~/.config`).
They move to `dot_config/<name>` in the chezmoi source:

| Current path | Chezmoi source name | Target |
|---|---|---|
| `btop/` | `dot_config/btop/` | `~/.config/btop/` |
| `gh/config.yml` | `dot_config/gh/config.yml` | `~/.config/gh/config.yml` |
| `git/` | `dot_config/git/` | `~/.config/git/` |
| `micro/` | `dot_config/micro/` | `~/.config/micro/` |
| `neofetch/` | `dot_config/neofetch/` | `~/.config/neofetch/` |
| `pypoetry/` | `dot_config/pypoetry/` | `~/.config/pypoetry/` |
| `systemd/` | `dot_config/systemd/` | `~/.config/systemd/` |
| `thefuck/` | `dot_config/thefuck/` | `~/.config/thefuck/` |
| `starship.toml` | `dot_config/starship.toml` | `~/.config/starship.toml` |
| `nix-manager/` | `dot_config/nix-manager/` | `~/.config/nix-manager/` |

### Do NOT rename / leave alone

| Path | Reason |
|---|---|
| `nvim/` | Submodule with its own repo and CLAUDE.md — manage separately |
| `gh/hosts.yml` | Gitignored (auth tokens) — handle in step 6 with age encryption |
| `plan/` | Meta-directory, not a dotfile |
| `arch/`, `apt/`, `brew/`, `nix/`, `nixos/`, `windows/` | Install scripts — not dotfiles |
| `scripts/` | Utility scripts — not dotfiles |
| `.github/` | CI config — not a dotfile |
| `CLAUDE.md` | Repo documentation — not a dotfile |

---

## Rename Procedure

Do this in three batches. After each batch: commit, then run `chezmoi apply --dry-run`
to confirm no unintended changes before running `chezmoi apply` for real.

### Batch 1 — Home dotfiles

```sh
cd ~/.config

# Move files to chezmoi names
git mv home/.zshrc    dot_zshrc.tmpl
git mv home/.zshenv   dot_zshenv.tmpl
git mv home/.zprofile dot_zprofile
git mv home/.tmux.conf dot_tmux.conf
git mv home/.gitconfig dot_gitconfig.tmpl

# Remove now-empty home/ directory
rmdir home
git add -A
git commit -m "chore: rename home dotfiles to chezmoi conventions"
```

Update `install.sh` symlink calls to point at new locations (or remove them —
chezmoi replaces the symlink logic entirely after step 2 is complete):
```sh
# In install.sh, temporarily update paths:
# link home/.zshrc → link dot_zshrc.tmpl
# ... etc
# This is a bridge — install.sh is deleted in step 5
```

After committing, re-home the symlinks:
```sh
# Remove old symlinks
rm ~/.zshrc ~/.zshenv ~/.zprofile ~/.tmux.conf ~/.gitconfig

# Let chezmoi manage them
chezmoi apply
```

Verify:
```sh
ls -la ~ | grep "zshrc\|zshenv\|zprofile\|tmux\|gitconfig"
# Should now be regular files managed by chezmoi, not symlinks
# (chezmoi writes files directly by default, not symlinks)
```

Note: chezmoi writes files, not symlinks. This is intentional — it means
`~/.zshrc` is a managed copy that chezmoi keeps in sync with the source.
To edit: `chezmoi edit ~/.zshrc` (opens source file, applies on save).

### Batch 2 — Claude settings

```sh
cd ~/.config
mkdir -p dot_claude
git mv claude/settings.json dot_claude/settings.json
rmdir claude
git commit -m "chore: rename claude settings to chezmoi conventions"

rm ~/.claude/settings.json
chezmoi apply
```

Verify: `cat ~/.claude/settings.json` should still have correct content.

### Batch 3 — ~/.config entries

```sh
cd ~/.config
mkdir -p dot_config

git mv btop        dot_config/btop
git mv gh/config.yml dot_config/gh/   # leave gh/hosts.yml gitignored where it is
git mv git         dot_config/git
git mv micro       dot_config/micro
git mv neofetch    dot_config/neofetch
git mv pypoetry    dot_config/pypoetry
git mv systemd     dot_config/systemd
git mv thefuck     dot_config/thefuck
git mv starship.toml dot_config/starship.toml
git mv nix-manager dot_config/nix-manager

git commit -m "chore: rename config entries to chezmoi conventions"
chezmoi apply --dry-run
chezmoi apply
```

---

## Post-Rename State

After all three batches the repo root looks like:

```
~/.config/
├── dot_zshrc.tmpl
├── dot_zshenv.tmpl
├── dot_zprofile
├── dot_tmux.conf
├── dot_gitconfig.tmpl
├── dot_claude/
├── dot_config/
├── arch/ apt/ brew/ nix/ nixos/ windows/
├── scripts/
├── plan/
├── install.sh          ← still present, removed in step 5
└── CLAUDE.md
```

---

## Verification Checklist

- [ ] `chezmoi status` shows all managed files, no unexpected diffs
- [ ] `chezmoi apply --dry-run` produces no changes (already up to date)
- [ ] Shell starts correctly (`exec zsh`)
- [ ] Tmux config loads (`tmux source ~/.tmux.conf`)
- [ ] `~/.claude/settings.json` intact
- [ ] `~/.config/starship.toml`, `btop/`, etc. all present and correct
- [ ] `nvim/` submodule unaffected
- [ ] `gh/hosts.yml` still gitignored and untouched

## Next Step

→ `03-templates.md`
