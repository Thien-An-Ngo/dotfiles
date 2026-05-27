{ config, pkgs, lib, ... }:
{
  # ── Zsh ───────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;

    # Oh My Zsh core
    oh-my-zsh = {
      enable  = true;
      theme   = "robbyrussell";
      # fzf-tab and forgit come in via programs.zsh.plugins below
      plugins = [ "git" "docker" "rust" "npm" ];
    };

    # External plugins managed by Nix (replaces manual OMZ custom installs)
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

    # Completion function directory
    completionInit = ''
      fpath+=~/.zfunc
      autoload -Uz compinit && compinit
      autoload -U bashcompinit && bashcompinit
    '';

    # ── Shell aliases ────────────────────────────────────────────────────
    # Unconditional in NixOS — all these packages are declared in tools.nix
    shellAliases = {
      # Modern replacements
      ls   = "lsd";
      ll   = "lsd -la";
      lt   = "lsd --tree";
      cat  = "bat";
      grep = "rg";
      find = "fd";
      top  = "btop";
      du   = "dust";
      ps   = "procs";
      y    = "yazi";
      http = "xh";
      help = "tldr";
      gu   = "gitui";
      bench = "hyperfine";
      pip  = "uv pip";
      watch = "watchexec";
      upgrade = "topgrade";
      jq   = "jq --tab";
      sysinfo = "macchina";
      ff   = "fastfetch";

      # Navigation
      ".."   = "cd ..";
      "..."  = "cd ../..";
      "...." = "cd ../../..";
      cd     = "z";   # zoxide

      # Tmux
      ta = "tmux attach -t";
      tn = "tmux new -s";
      tl = "tmux ls";
      tk = "tmux kill-session -t";

      # Quick config edits
      zshrc  = "\${EDITOR:-nvim} ~/.zshrc";
      vimrc  = "\${EDITOR:-nvim} ~/.config/nvim/init.lua";
      tmuxrc = "\${EDITOR:-nvim} ~/.tmux.conf";

      # Git shortcuts (additive to OMZ git plugin)
      g    = "git";
      glog = "git log --oneline --graph --decorate";

      # WSL clipboard
      pbcopy   = "clip.exe";
      pbpaste  = "powershell.exe -command Get-Clipboard";
    };

    # ── Session variables ────────────────────────────────────────────────
    sessionVariables = {
      # fzf: Dracula/pastel colour scheme matching starship palette
      FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git 2>/dev/null || find . -type f";
      FZF_DEFAULT_OPTS    = ''
        --color=fg:#f8f8f2,bg:#21222c,hl:#9A348E
        --color=fg+:#f8f8f2,bg+:#44475a,hl+:#DA627D
        --color=info:#FCA17D,prompt:#DA627D,pointer:#9A348E
        --color=marker:#86BBD8,spinner:#FCA17D,header:#6272a4
        --height 40% --border --reverse
      '';

      BUN_INSTALL = "$HOME/.bun";
      NVM_DIR     = "$HOME/.nvm";
      EDITOR      = "nvim";
    };

    # ── initExtra: things that must run in-order at shell startup ────────
    initExtra = ''
      # ── Tmux autostart (WSL — skip if already in tmux or in VSCode) ──
      if [ -z "$TMUX" ] && [ -t 0 ] && [ "$TERM_PROGRAM" != "vscode" ]; then
        exec tmux new-session -A -s main
      fi

      # ── fzf-tab appearance ────────────────────────────────────────────
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*'         fzf-preview 'lsd --color=always $realpath 2>/dev/null || ls --color=always $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd --color=always $realpath 2>/dev/null || ls --color=always $realpath'
      zstyle ':fzf-tab:*' fzf-flags --color='hl:#9A348E,hl+:#DA627D'

      # ── PATH additions for externally-managed runtimes ────────────────
      # (Nix-managed packages are already on PATH via ~/.nix-profile)
      export PATH="$HOME/.bun/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

      # ── Bun ──────────────────────────────────────────────────────────
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

      # ── Pyenv ────────────────────────────────────────────────────────
      if command -v pyenv &>/dev/null; then
        export PYENV_ROOT="$HOME/.pyenv"
        eval "$(pyenv init -)"
      fi

      # ── Node (mise takes priority over nvm) ──────────────────────────
      if command -v mise &>/dev/null; then
        eval "$(mise activate zsh)"
      else
        # nvm — lazy-loaded to avoid ~500ms startup penalty
        nvm()  { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; nvm  "$@"; }
        node() { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; node "$@"; }
        npm()  { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; npm  "$@"; }
        npx()  { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; npx  "$@"; }
        yarn() { unset -f nvm node npm npx yarn; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"; yarn "$@"; }
        [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
      fi

      # ── pipx completions ──────────────────────────────────────────────
      command -v pipx &>/dev/null && eval "$(register-python-argcomplete pipx)"

      # ── navi cheatsheet picker (Ctrl+G) ───────────────────────────────
      command -v navi &>/dev/null && eval "$(navi widget zsh)"

      # ── OpenClaw completions (if installed) ───────────────────────────
      [ -f "$HOME/.openclaw/completions/openclaw.zsh" ] && \
        source "$HOME/.openclaw/completions/openclaw.zsh"

      # ── WSL clipboard helpers ─────────────────────────────────────────
      fclip() { cat "$1" | clip.exe; }

      # ── Machine-local overrides (API keys, machine-specific PATH, etc.) ─
      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
    '';
  };

  # ── Starship — config file is linked in default.nix ──────────────────
  programs.starship.enable = true;

  # ── Atuin — magic shell history, wins the Ctrl+R binding ─────────────
  programs.atuin = {
    enable  = true;
    enableZshIntegration = true;
    settings = {
      style     = "compact";
      inline_height = 15;
    };
  };

  # ── Zoxide — smart cd replacement ────────────────────────────────────
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── FZF — fuzzy finder (Ctrl+R history / Ctrl+T files / Alt+C cd) ────
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── Thefuck — command correction ─────────────────────────────────────
  programs.thefuck = {
    enable = true;
    enableZshIntegration = true;
  };

  # ── Zshenv: sourced by every zsh invocation ───────────────────────────
  home.file.".zshenv".text = ''
    . "$HOME/.cargo/env"
  '';
}
