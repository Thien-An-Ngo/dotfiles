{ config, pkgs, lib, vars, ... }:
let
  c = vars.colors; # shorthand so color interpolations stay readable
in
{
  # ── Zsh ───────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;

    # Sourced for EVERY zsh invocation (login, interactive, scripts).
    # Keep minimal — only truly global env belongs here.
    envExtra = ''. "$HOME/.cargo/env"'';

    # Login-shell only: pyenv shim PATH must be set before .zshrc runs
    # so that the correct python/pip are on PATH in every subshell.
    profileExtra = ''
      export PYENV_ROOT="$HOME/.pyenv"
      [[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
      command -v pyenv &>/dev/null && eval "$(pyenv init --path)"
      export PATH="$HOME/.local/bin:$PATH"
    '';

    # Oh My Zsh
    oh-my-zsh = {
      enable  = true;
      theme   = "robbyrussell";
      plugins = [ "git" "docker" "rust" "npm" ];
    };

    # Nix-managed external plugins (replaces manual $ZSH_CUSTOM installs)
    plugins = [
      {
        name = "fzf-tab";
        src  = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "forgit";
        src  = pkgs.forgit;
        file = "share/forgit/forgit.plugin.zsh";
      }
    ];

    # fpath must be extended before compinit; bashcompinit needed for pipx
    completionInit = ''
      fpath+=~/.zfunc
      autoload -Uz compinit && compinit
      autoload -U bashcompinit && bashcompinit
    '';

    # ── Aliases ───────────────────────────────────────────────────────
    # All packages are declared in tools.nix so aliases are unconditional.
    shellAliases = {
      ls      = "lsd";
      ll      = "lsd -la";
      lt      = "lsd --tree";
      cat     = "bat";
      grep    = "rg";
      find    = "fd";
      top     = "btop";
      du      = "dust";
      ps      = "procs";
      y       = "yazi";
      http    = "xh";
      help    = "tldr";
      gu      = "gitui";
      bench   = "hyperfine";
      pip     = "uv pip";
      watch   = "watchexec";
      upgrade = "topgrade";
      jq      = "jq --tab";
      sysinfo = "macchina";
      ff      = "fastfetch";

      # Navigation
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "...." = "cd ../../..";
      cd     = "z"; # zoxide

      # Tmux
      ta = "tmux attach -t";
      tn = "tmux new -s";
      tl = "tmux ls";
      tk = "tmux kill-session -t";

      # Quick config edits
      zshrc  = "\${EDITOR:-nvim} ~/.zshrc";
      vimrc  = "\${EDITOR:-nvim} ~/.config/nvim/init.lua";
      tmuxrc = "\${EDITOR:-nvim} ~/.tmux.conf";

      # Git (additive to OMZ git plugin)
      g    = "git";
      glog = "git log --oneline --graph --decorate";
    }
    # WSL-only: Windows clipboard binaries
    // lib.optionalAttrs (vars.platform == "wsl") {
      pbcopy  = "clip.exe";
      pbpaste = "powershell.exe -command Get-Clipboard";
    };

    # ── Session variables ─────────────────────────────────────────────
    sessionVariables = {
      FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f";
      # Colors sourced from vars.colors — single source of truth
      FZF_DEFAULT_OPTS = ''
        --color=fg:${c.fg},bg:${c.bg},hl:${c.purple}
        --color=fg+:${c.fg},bg+:${c.bgAlt},hl+:${c.salmon}
        --color=info:${c.peach},prompt:${c.salmon},pointer:${c.purple}
        --color=marker:${c.steel},spinner:${c.peach},header:${c.comment}
        --height 40% --border --reverse
      '';
      BUN_INSTALL = "$HOME/.bun";
      NVM_DIR     = "$HOME/.nvm";
      EDITOR      = "nvim";
    };

    # ── initExtra ─────────────────────────────────────────────────────
    initExtra =
      # ── Common — runs on every interactive shell ─────────────────────
      ''
        # Tmux autostart — skip if already inside tmux or inside VSCode
        if [ -z "$TMUX" ] && [ -t 0 ] && [ "$TERM_PROGRAM" != "vscode" ]; then
          exec tmux new-session -A -s main
        fi

        # fzf-tab: directory preview + palette from vars.colors
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*'         fzf-preview 'lsd --color=always $realpath 2>/dev/null || ls --color=always $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd --color=always $realpath 2>/dev/null || ls --color=always $realpath'
        zstyle ':fzf-tab:*' fzf-flags --color='hl:${c.purple},hl+:${c.salmon}'

        # PATH: externally-managed runtimes (Nix packages already on PATH)
        export PATH="$HOME/.bun/bin:$HOME/.cargo/bin:$PATH"

        # Bun completions
        [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

        # Pyenv shell functions (--path setup is in profileExtra)
        if command -v pyenv &>/dev/null; then
          eval "$(pyenv init -)"
        fi

        # Node: mise takes priority; nvm lazy-loaded to avoid ~500ms startup hit
        if command -v mise &>/dev/null; then
          eval "$(mise activate zsh)"
        else
          nvm()  { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm  "$@"; }
          node() { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; node "$@"; }
          npm()  { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; npm  "$@"; }
          npx()  { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; npx  "$@"; }
          yarn() { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; yarn "$@"; }
          [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
        fi

        # pipx argcomplete (requires bashcompinit from completionInit)
        command -v pipx &>/dev/null && eval "$(register-python-argcomplete pipx)"

        # navi cheatsheet picker (Ctrl+G)
        command -v navi &>/dev/null && eval "$(navi widget zsh)"

        # OpenClaw completions (optional)
        [ -f "$HOME/.openclaw/completions/openclaw.zsh" ] && \
          source "$HOME/.openclaw/completions/openclaw.zsh"

      ''
      # ── WSL-specific ─────────────────────────────────────────────────
      + lib.optionalString (vars.platform == "wsl") ''
        fclip() { cat "$1" | clip.exe; }
      ''
      # ── Native Linux clipboard (Wayland-aware) ────────────────────────
      + lib.optionalString (vars.platform != "wsl") ''
        pbcopy() {
          if [[ -n "$WAYLAND_DISPLAY" ]]; then wl-copy; else xclip -sel clip; fi
        }
        pbpaste() {
          if [[ -n "$WAYLAND_DISPLAY" ]]; then wl-paste; else xclip -o -sel clip; fi
        }
        fclip() {
          if [[ -n "$WAYLAND_DISPLAY" ]]; then wl-copy < "$1"; else xclip -sel clip < "$1"; fi
        }
      ''
      # ── Always last: machine-local overrides ─────────────────────────
      + ''
        [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
      '';
  };

  # ── direnv + nix-direnv ───────────────────────────────────────────────
  # `cd` into any project with a flake.nix or shell.nix and the right
  # runtime (Node, Python, Rust…) loads automatically. Replaces most of
  # the per-project need for pyenv/nvm.
  programs.direnv = {
    enable               = true;
    enableZshIntegration = true;
    nix-direnv.enable    = true;
  };

  # ── Starship — config file linked in default.nix ──────────────────────
  programs.starship.enable = true;

  # ── Atuin — searchable shell history; wins the Ctrl+R binding ─────────
  programs.atuin = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      style        = "compact";
      inline_height = 15;
    };
  };

  # ── Zoxide — smart cd ─────────────────────────────────────────────────
  programs.zoxide = {
    enable               = true;
    enableZshIntegration = true;
  };

  # ── FZF — Ctrl+R / Ctrl+T / Alt+C ────────────────────────────────────
  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
  };

  # ── Thefuck — command correction ──────────────────────────────────────
  programs.thefuck = {
    enable               = true;
    enableZshIntegration = true;
  };
}
