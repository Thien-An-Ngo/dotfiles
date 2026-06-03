# Step 1 — Init Chezmoi and Import Existing Files

## Goal

Install chezmoi on the current machine and point it at the existing `~/.config`
repo without moving any files yet. Verify chezmoi can see and manage the current
dotfiles before making any structural changes.

## Context

The repo currently lives at `~/.config` and uses a hand-rolled `install.sh` for
symlinking. Chezmoi expects its source directory at `~/.local/share/chezmoi`.
This step bridges the two without disrupting the live setup.

---

## Pre-flight Checks

```sh
# Confirm current symlink state is clean
ls -la ~ | grep "\.zshrc\|\.zshenv\|\.tmux\|\.gitconfig"
# All should point into ~/.config/home/

# Confirm the repo remote
git -C ~/.config remote -v
# Should show github.com/thien-an-ngo/.config (or dotfiles)
```

---

## 1.1 Install Chezmoi

On Arch:
```sh
yay -S chezmoi
```

On any system (binary install, no package manager needed):
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
```

Verify:
```sh
chezmoi --version
```

---

## 1.2 Point Chezmoi at the Existing Repo

Do NOT run `chezmoi init <repo>` yet — that would clone fresh and ignore the
existing `~/.config`. Instead, tell chezmoi to use `~/.config` as its source:

```sh
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml << 'EOF'
[chezmoi]
    sourceDir = "/home/<youruser>/.config"
EOF
```

Replace `<youruser>` with your actual username. This is the machine-local chezmoi
config — it is never committed.

Verify chezmoi can see the source:
```sh
chezmoi source-path
# Should print: /home/<youruser>/.config
```

---

## 1.3 Dry-Run to Understand Current State

Before importing anything, see what chezmoi thinks about the current state:

```sh
chezmoi status
```

At this point chezmoi knows about no files yet (none are named with chezmoi
conventions). Output should be empty or minimal. That is expected.

```sh
chezmoi doctor
```

Fix any reported issues (usually just missing age binary or similar).

---

## 1.4 Import the First File as a Test

Import `.zshrc` as a trial run before committing to the full rename in step 2:

```sh
# This copies ~/.zshrc into chezmoi source with correct naming
chezmoi add ~/.zshrc
```

This will create `~/.config/dot_zshrc` (a copy). Verify:
```sh
ls ~/.config/dot_zshrc
chezmoi status   # should now show .zshrc as managed
chezmoi diff     # should show no diff (file identical to target)
```

**Important:** `chezmoi add` creates a copy. The original symlink at `~/.zshrc`
still points to `~/.config/home/.zshrc`. You now have two source-of-truth files.
Do not edit `home/.zshrc` after this point — edit via `chezmoi edit ~/.zshrc`
or directly in the source as `dot_zshrc`.

Remove the test import for now — the full rename happens in step 2:
```sh
chezmoi forget ~/.zshrc
rm ~/.config/dot_zshrc
```

---

## 1.5 Plan the Repo Rename

The repo is currently called `.config` on GitHub. Before step 2, rename it to
`dotfiles` on GitHub (Settings → Repository name). This is cosmetic but important
for the `chezmoi init github.com/thien-an-ngo/dotfiles` bootstrap command to work.

Update the local remote:
```sh
git -C ~/.config remote set-url origin git@github.com:thien-an-ngo/dotfiles.git
```

---

## Verification Checklist

- [ ] `chezmoi --version` prints a version
- [ ] `chezmoi source-path` returns `~/.config`
- [ ] `chezmoi doctor` reports no errors
- [ ] `chezmoi add` / `chezmoi forget` test cycle completed cleanly
- [ ] GitHub repo renamed to `dotfiles`
- [ ] Local remote URL updated

## Next Step

→ `02-file-renaming.md`
