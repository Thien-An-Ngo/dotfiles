{ config, pkgs, ... }:

{
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # ── Shell ──────────────────────────────────────────────────────────────
    zsh
    starship
    fzf
    zoxide
    atuin

    # ── Terminal multiplexer ───────────────────────────────────────────────
    tmux

    # ── Editor ────────────────────────────────────────────────────────────
    neovim

    # ── Modern CLI replacements ────────────────────────────────────────────
    lsd
    bat
    ripgrep
    fd
    btop
    dust
    procs
    yazi
    xh
    lazygit
    gitui
    bottom          # btm
    dua
    skim            # sk
    git-delta       # delta
    hyperfine
    tealdeer        # tldr
    watchexec
    topgrade

    # ── Git & GitHub ──────────────────────────────────────────────────────
    gh
    navi

    # ── Navigation & search ───────────────────────────────────────────────
    jq
    yq-go
    fx

    # ── Runtimes ──────────────────────────────────────────────────────────
    rustup
    bun
    pyenv
    uv
    pipx
    mise

    # ── Productivity ──────────────────────────────────────────────────────
    taskwarrior3
    timewarrior
    just
    entr
    pet

    # ── Docker tools ──────────────────────────────────────────────────────
    ctop
    lazydocker

    # ── TUI tools ─────────────────────────────────────────────────────────
    macchina
    fastfetch

    # ── Database ──────────────────────────────────────────────────────────
    pgcli

    # ── Notes & knowledge ─────────────────────────────────────────────────
    nb
    dnote

    # ── Remote ────────────────────────────────────────────────────────────
    mosh
    tmate

    # ── Misc utilities ────────────────────────────────────────────────────
    kalker
    atac
    # posting   # check nixpkgs if available: pkgs.posting
    gdu
    lychee
    mani

    # ── Core utils ────────────────────────────────────────────────────────
    curl
    wget
    unzip
    git
  ];
}
