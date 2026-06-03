# Step 6 — Secrets Management with Age Encryption

## Goal

Encrypt files that contain credentials or tokens so they can be committed to
the public repo without exposing secrets. Primary target: `gh/hosts.yml`
(GitHub CLI auth tokens). Secondary: any future API keys or credentials.

---

## Why Age Over GPG

- Age is simpler: one key, one file, no keyring daemon
- Chezmoi has native age support
- Key is a single file you back up once
- No expiry, no web of trust complexity
- Chezmoi docs recommend age as the default

---

## 6.1 Install Age

```sh
# Arch
sudo pacman -S age

# apt
sudo apt-get install age

# brew
brew install age

# Any platform (binary)
# Download from https://github.com/FiloSottile/age/releases
```

---

## 6.2 Generate an Age Key

```sh
age-keygen -o ~/.config/chezmoi/key.txt
```

Output looks like:
```
# created: 2026-06-03T...
# public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Back this key up immediately** — without it, encrypted files in the repo are
unrecoverable. Options:
- Print and store physically
- Save to a password manager (Bitwarden, 1Password)
- Store in a private location outside this repo

The key file stays at `~/.config/chezmoi/key.txt` — it is never committed.

---

## 6.3 Configure Chezmoi to Use the Key

Add to `~/.config/chezmoi/chezmoi.toml` (the machine-local config, not the template):

```toml
[age]
    identity   = "~/.config/chezmoi/key.txt"
    recipients = ["age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"]
```

Replace the recipients value with your actual public key from step 6.2.

To add this automatically during `chezmoi init`, add to `.chezmoi.toml.tmpl`:

```toml
{{- $ageKey := promptStringOnce . "ageRecipient" "Age public key (leave blank to skip encryption)" -}}

{{- if $ageKey }}
[age]
    identity   = "{{ .chezmoi.homeDir }}/.config/chezmoi/key.txt"
    recipients = [{{ $ageKey | quote }}]
{{- end }}
```

On a machine where you have the key, fill in the public key. On a machine where
you do not (e.g. a server where you only need non-secret dotfiles), leave blank —
chezmoi will skip decryption of encrypted files and they will not be written.

---

## 6.4 Encrypt `gh/hosts.yml`

`gh/hosts.yml` is currently gitignored. To commit it encrypted:

```sh
# First, make sure gh/hosts.yml exists and has valid content
cat ~/.config/gh/hosts.yml

# Encrypt it into the chezmoi source as an encrypted file
# The source name uses the 'encrypted_' prefix
chezmoi add --encrypt ~/.config/gh/hosts.yml
```

This creates `dot_config/gh/encrypted_hosts.yml` in the source. The content is
the age-encrypted ciphertext. It is safe to commit to a public repo.

Remove `gh/hosts.yml` from `.gitignore` (it no longer needs to be ignored —
the plaintext version is never in the source dir):
```sh
# In .gitignore / .chezmoiignore, remove:
gh/hosts.yml

# The encrypted version is now tracked:
dot_config/gh/encrypted_hosts.yml
```

---

## 6.5 How Decryption Works on a New Machine

On `chezmoi apply`:
1. Chezmoi reads `~/.config/chezmoi/chezmoi.toml` for the `[age]` block
2. Finds `dot_config/gh/encrypted_hosts.yml` in source
3. Decrypts using the identity file
4. Writes plaintext to `~/.config/gh/hosts.yml`

If no age identity is configured, chezmoi skips encrypted files with a warning.
The machine functions normally — it just needs to re-authenticate with `gh auth login`.

---

## 6.6 Future Secrets

Any file containing credentials follows the same pattern:
```sh
chezmoi add --encrypt ~/.path/to/secret/file
```

Candidates to encrypt if they ever contain credentials:
- `~/.config/atuin/key` (atuin sync key)
- `~/.ssh/config` if it contains hostnames you prefer private (use `private_` prefix instead for permissions, `encrypted_` for content)
- Any `.env` files tracked in the dotfiles

Note: SSH private keys (`~/.ssh/id_ed25519`) should NOT be in this repo even encrypted.
Manage them out-of-band. Only SSH `config` (public, no credentials) belongs here,
and it uses `private_dot_ssh/config` for the 600 permission, not encryption.

---

## 6.7 Re-keying

If your age key is ever compromised:
1. Generate a new key
2. `chezmoi re-add --encrypt` on all encrypted files with the new key
3. Commit the re-encrypted files
4. Revoke/rotate the underlying credentials (the encryption protects the file,
   but if the key was compromised the credentials themselves should be rotated)

---

## Verification Checklist

- [ ] `age` installed
- [ ] Age key generated at `~/.config/chezmoi/key.txt`
- [ ] Key backed up to password manager or physical storage
- [ ] `chezmoi.toml` (machine-local) has `[age]` block configured
- [ ] `.chezmoi.toml.tmpl` prompts for age recipient key on init
- [ ] `gh/hosts.yml` encrypted and committed as `dot_config/gh/encrypted_hosts.yml`
- [ ] `gh/hosts.yml` removed from `.gitignore`
- [ ] `chezmoi apply` decrypts and writes `~/.config/gh/hosts.yml` correctly
- [ ] `gh auth status` works after fresh `chezmoi apply`

## Next Step

→ `07-windows.md`
