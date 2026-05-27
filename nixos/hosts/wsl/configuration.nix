{ config, lib, pkgs, ... }:
{
  # ── WSL2 integration ──────────────────────────────────────────────────
  wsl = {
    enable      = true;
    defaultUser = "thienan";
    # Expose Windows Start Menu entries for Linux GUI apps
    startMenuLaunchers = true;
    # Interop: run .exe helpers (clip.exe, powershell.exe, etc.)
    interop.includePath = false; # keep Windows PATH out of Linux PATH
  };

  # ── User ──────────────────────────────────────────────────────────────
  users.users.thienan = {
    isNormalUser = true;
    shell        = pkgs.zsh;
    extraGroups  = [ "wheel" "docker" ];
  };

  # ── Nix settings ──────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Public binary caches for faster builds
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # ── Docker (rootless friendly on WSL2) ───────────────────────────────
  virtualisation.docker = {
    enable        = true;
    rootless = {
      enable        = true;
      setSocketVariable = true;
    };
  };

  # ── Minimal system-wide packages (rest managed by home-manager) ───────
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    gnumake
    unzip
    gcc  # needed by some build tools
  ];

  # ── Programs that need system-level enablement ────────────────────────
  programs.zsh.enable = true;  # required for it to be a valid login shell

  system.stateVersion = "24.11";
}
