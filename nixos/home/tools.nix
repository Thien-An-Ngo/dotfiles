{ config, pkgs, lib, vars, ... }:
{
  home.packages = with pkgs; [
    # ── Modern Unix replacements ───────────────────────────────────────
    lsd       # ls  → lsd
    bat       # cat → bat
    ripgrep   # grep → rg
    fd        # find → fd
    btop      # top  → btop
    du-dust   # du   → dust
    procs     # ps   → procs
    bottom    # btm  (alternative to btop)
    dua       # disk usage analyser

    # ── Terminal / shell utilities ─────────────────────────────────────
    yazi      # file manager (alias: y)
    xh        # HTTP client (alias: http)
    navi      # interactive cheatsheet picker (Ctrl+G)
    skim      # fzf alternative (sk)
    watchexec # watch + run on change
    hyperfine # benchmarking (alias: bench)
    topgrade  # upgrade all the things (alias: upgrade)
    fastfetch # system info (alias: ff)
    macchina  # sysinfo (alias: sysinfo)
    neofetch  # legacy sysinfo

    # ── Git extras ────────────────────────────────────────────────────
    lazygit   # TUI git client
    gitui     # TUI git client (alias: gu)
    git-absorb # auto-fixup commits
    delta     # diff pager (also wired in programs.git.delta)

    # ── Data / JSON ───────────────────────────────────────────────────
    jq        # JSON processor (alias: jq --tab)
    yq-go     # YAML/JSON/TOML processor (yq)
    fx        # interactive JSON viewer

    # ── Docs / help ───────────────────────────────────────────────────
    tealdeer  # tldr pages (alias: help)
    manix     # search NixOS/home-manager options

    # ── Editors ───────────────────────────────────────────────────────
    micro     # micro editor

    # ── Build / task runners ──────────────────────────────────────────
    just      # justfile task runner
    entr      # run commands on file changes
    gnumake

    # ── Task management ───────────────────────────────────────────────
    taskwarrior3 # task
    timewarrior  # timew

    # ── Database ──────────────────────────────────────────────────────
    pgcli     # PostgreSQL CLI with autocomplete

    # ── Docker utilities ──────────────────────────────────────────────
    lazydocker # TUI docker client
    ctop       # container top

    # ── Remote / SSH ──────────────────────────────────────────────────
    mosh      # resilient SSH
    tmate     # instant terminal sharing

    # ── Runtime version managers ──────────────────────────────────────
    mise      # polyglot version manager (replaces nvm + pyenv for most use)
    pyenv     # Python version manager
    rustup    # Rust toolchain manager
    bun       # JS runtime + package manager
    uv        # fast Python package manager

    # ── Python tooling ────────────────────────────────────────────────
    pipx      # install Python CLIs in isolated envs
    python3   # system-level Python

    # ── Node tooling ──────────────────────────────────────────────────
    nodejs    # system-level Node (project Nodes via nvm/mise)

    # ── Nix tooling ───────────────────────────────────────────────────
    nh                 # nicer `home-manager switch` / `nixos-rebuild` UX
    nix-output-monitor # coloured, structured nix build output
    alejandra          # opinionated Nix formatter (used by `nix fmt`)

    # ── Clipboard (native Linux only — WSL uses clip.exe via PATH) ────
  ] ++ lib.optionals (vars.platform != "wsl") [
    xclip        # X11 clipboard
    wl-clipboard # Wayland: wl-copy / wl-paste
  ]

  # ── Misc productivity ──────────────────────────────────────────────
  ++ [
    bc       # POSIX calculator
    kalker   # interactive calculator
    lychee   # link checker
  ];
}
