{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # ── Modern Unix replacements ───────────────────────────────────────
    lsd          # ls → lsd
    bat          # cat → bat
    ripgrep      # grep → rg
    fd           # find → fd
    btop         # top → btop
    du-dust      # du → dust
    procs        # ps → procs
    bottom       # btm (alternative top)
    dua          # disk usage analyser

    # ── Terminal / shell utilities ─────────────────────────────────────
    yazi         # file manager (alias: y)
    xh           # HTTP client (alias: http)
    navi         # interactive cheatsheet picker (Ctrl+G)
    skim         # fzf alternative (sk)
    watchexec    # watch + run on change
    hyperfine    # benchmarking (alias: bench)
    topgrade     # upgrade all the things (alias: upgrade)
    fastfetch    # system info (alias: ff)
    macchina     # sysinfo (alias: sysinfo)
    neofetch     # legacy sysinfo

    # ── Git extras ────────────────────────────────────────────────────
    lazygit      # TUI git client
    gitui        # TUI git client (alias: gu)
    git-absorb   # auto-fixup commits
    delta        # diff pager (also used by programs.git.delta)

    # ── Data / JSON ───────────────────────────────────────────────────
    jq           # JSON processor (alias: jq --tab)
    yq-go        # YAML/JSON processor (yq)
    fx           # interactive JSON viewer

    # ── Docs / help ───────────────────────────────────────────────────
    tealdeer     # tldr pages (alias: help)
    manix        # search NixOS/home-manager options

    # ── Editors ───────────────────────────────────────────────────────
    micro        # micro editor

    # ── Build / task runners ──────────────────────────────────────────
    just         # task runner (justfile)
    entr         # run commands on file changes
    gnumake

    # ── Task management ───────────────────────────────────────────────
    taskwarrior3 # task
    timewarrior  # timew

    # ── Database ──────────────────────────────────────────────────────
    pgcli        # PostgreSQL CLI with autocomplete

    # ── Docker utilities ──────────────────────────────────────────────
    lazydocker   # TUI docker client
    ctop         # container top

    # ── Remote / SSH ──────────────────────────────────────────────────
    mosh         # resilient SSH
    tmate        # instant terminal sharing

    # ── Runtime version managers ──────────────────────────────────────
    # These sit alongside Nix-managed runtimes for project-level pinning
    mise         # polyglot version manager (replaces nvm + pyenv)
    pyenv        # Python version manager
    rustup       # Rust toolchain manager
    bun          # JS runtime + package manager
    uv           # fast Python package manager

    # ── Python tooling ────────────────────────────────────────────────
    pipx         # install Python CLI tools in isolated envs
    python3      # system-level Python (project Pythons managed by pyenv/mise)

    # ── Node tooling ──────────────────────────────────────────────────
    nodejs       # system-level Node (project Nodes managed by nvm/mise)

    # ── Misc productivity ─────────────────────────────────────────────
    bc           # calculator (bcal replacement)
    kalker       # interactive calculator
    lychee       # link checker
  ];
}
