# Chezmoi Restructure — Overview

Full migration from the current symlink-based dotfiles to chezmoi.
Each step is independently shippable. Do not proceed to the next step
until the current one is verified working on the live machine.

## Steps

| # | Plan file | What it covers |
|---|---|---|
| 1 | `01-init-and-import.md` | Install chezmoi, point it at the existing repo, import current files |
| 2 | `02-file-renaming.md` | Rename all source files to chezmoi conventions (`dot_`, etc.) |
| 3 | `03-templates.md` | Add `.chezmoi.toml.tmpl`, convert hardcoded values to template variables |
| 4 | `04-externals.md` | Migrate all `git clone` calls to `.chezmoiexternal.toml` |
| 5 | `05-run-once-install.md` | Convert install scripts into `run_once_install.sh.tmpl` |
| 6 | `06-secrets.md` | Add age encryption for `gh/hosts.yml` and any other secrets |
| 7 | `07-windows.md` | Windows-native support via PowerShell + Scoop/winget |

## Constraints

- Repo currently lives at `~/.config` — must migrate to `~/.local/share/chezmoi`
  without breaking the live machine mid-migration
- `nvim/` is a submodule with its own repo — handle separately, do not fold into chezmoi
- `gh/hosts.yml` is gitignored (contains auth tokens) — must stay secret throughout
- Each step must leave the machine in a working state

## Reference

- Chezmoi docs: https://www.chezmoi.io/user-guide/setup/
- Template reference: https://www.chezmoi.io/reference/templates/
- External files: https://www.chezmoi.io/user-guide/advanced/manage-external-files/
