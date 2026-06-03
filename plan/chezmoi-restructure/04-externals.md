# Step 4 — Migrate Git Clones to `.chezmoiexternal.toml`

## Goal

Replace all manual `git clone` calls in `install.sh` and the install scripts
with a declarative `.chezmoiexternal.toml`. Chezmoi will clone, update, and
manage these external repos automatically on every `chezmoi apply`.

---

## What Gets Migrated

| Currently cloned by | Target path | Source |
|---|---|---|
| `install.sh` | `~/.oh-my-zsh` | ohmyzsh/ohmyzsh |
| `install.sh` | `~/.tmux/plugins/tpm` | tmux-plugins/tpm |
| `install.sh` | `~/.oh-my-zsh/custom/plugins/fzf-tab` | Aloxaf/fzf-tab |
| `install.sh` | `~/.oh-my-zsh/custom/plugins/forgit` | wfxr/forgit |

---

## 4.1 Create `.chezmoiexternal.toml`

Place at the root of the chezmoi source directory:

```toml
# Oh My Zsh
[".oh-my-zsh"]
    type          = "git-repo"
    url           = "https://github.com/ohmyzsh/ohmyzsh.git"
    refreshPeriod = "168h"    # re-fetch at most once per week on chezmoi update
    [".oh-my-zsh".pull]
        args = ["--ff-only"]  # safe: never creates merge commits

# Tmux Plugin Manager
[".tmux/plugins/tpm"]
    type          = "git-repo"
    url           = "https://github.com/tmux-plugins/tpm.git"
    refreshPeriod = "168h"

# Oh My Zsh custom plugins
[".oh-my-zsh/custom/plugins/fzf-tab"]
    type          = "git-repo"
    url           = "https://github.com/Aloxaf/fzf-tab.git"
    refreshPeriod = "168h"

[".oh-my-zsh/custom/plugins/forgit"]
    type          = "git-repo"
    url           = "https://github.com/wfxr/forgit.git"
    refreshPeriod = "168h"
```

After adding this file:
```sh
chezmoi apply
```

Chezmoi will clone all four repos on first apply. On subsequent runs it checks
the `refreshPeriod` — if it has been less than the period since the last fetch,
it skips. `chezmoi update` always refreshes regardless of period.

---

## 4.2 Verify External Repos Are Managed

```sh
chezmoi status
# External repos should appear in output

ls ~/.oh-my-zsh
ls ~/.tmux/plugins/tpm
ls ~/.oh-my-zsh/custom/plugins/fzf-tab
ls ~/.oh-my-zsh/custom/plugins/forgit
```

Test that Oh My Zsh still loads:
```sh
exec zsh
# Should load without errors
```

---

## 4.3 Remove Git Clone Calls from install.sh

Once externals are verified working, remove the following blocks from `install.sh`:

```sh
# DELETE these blocks:
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL ...ohmyzsh...)" "" --unattended
fi

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ...
fi

FZF_TAB_DIR=...
if [ ! -d "$FZF_TAB_DIR" ]; then
    git clone https://github.com/Aloxaf/fzf-tab ...
fi

FORGIT_DIR=...
if [ ! -d "$FORGIT_DIR" ]; then
    git clone https://github.com/wfxr/forgit ...
fi
```

Also remove the same blocks from `arch/install.sh`, `apt/install.sh`,
`brew/install.sh`, and `nix/install.sh` — chezmoi handles this for all of them.

Commit:
```sh
git add .chezmoiexternal.toml install.sh arch/install.sh apt/install.sh \
        brew/install.sh nix/install.sh
git commit -m "chore: migrate external git repos to .chezmoiexternal.toml"
```

---

## 4.4 Handling the Oh My Zsh Install Script

Oh My Zsh was previously installed via its own `install.sh` curl script, which
does more than `git clone` (sets up `.zshrc`, backs up existing shell files, etc.).

Using `git-repo` type in `.chezmoiexternal.toml` is cleaner — it just clones the
repo without touching `.zshrc`. Since chezmoi manages `.zshrc` directly, the
Oh My Zsh installer's `.zshrc` manipulation is unwanted anyway.

The `export ZSH="$HOME/.oh-my-zsh"` and `source $ZSH/oh-my-zsh.sh` in `.zshrc`
is sufficient. No installer script needed.

---

## 4.5 NVM Edge Case

NVM's install script does more than clone — it modifies `.zshrc`/`.bashrc`.
Since chezmoi owns `.zshrc`, do NOT put NVM in `.chezmoiexternal.toml`.
NVM installation stays in the `run_once_install.sh.tmpl` (step 5), and the
`.zshrc` template already has the correct NVM init lines hardcoded.

Same applies to: rustup, pyenv, bun. These are runtimes managed by the install
scripts, not static repos managed by externals.

---

## Verification Checklist

- [ ] `.chezmoiexternal.toml` committed
- [ ] `chezmoi apply` clones all four external repos
- [ ] `exec zsh` loads Oh My Zsh, fzf-tab, and forgit without errors
- [ ] Tmux `Prefix+I` still works for TPM plugin installation
- [ ] All `git clone` calls removed from `install.sh` and system installers
- [ ] `chezmoi update` refreshes external repos correctly

## Next Step

→ `05-run-once-install.md`
