{ config, pkgs, vars, ... }:
{
  imports = [
    ./shell.nix
    ./tmux.nix
    ./git.nix
    ./tools.nix
    ./services.nix
  ];

  home.username      = vars.username;
  home.homeDirectory = vars.homeDir;
  home.stateVersion  = "24.11";

  programs.home-manager.enable = true;

  xdg.enable = true;

  # ── Config files referenced verbatim from the dotfiles repo ──────────
  # Starship: use the checked-in TOML rather than translating to Nix attrs
  xdg.configFile."starship.toml".source = ../starship.toml;

  # btop, neofetch — copy configs as-is
  xdg.configFile."btop/btop.conf".source     = ../btop/btop.conf;
  xdg.configFile."neofetch/config.conf".source = ../neofetch/config.conf;

  # micro editor
  xdg.configFile."micro/bindings.json".source = ../micro/bindings.json;
  xdg.configFile."micro/settings.json".source = ../micro/settings.json;

  # pypoetry
  xdg.configFile."pypoetry/config.toml".source = ../pypoetry/config.toml;

  # gh (sans hosts.yml which holds auth tokens)
  xdg.configFile."gh/config.yml".source = ../gh/config.yml;
}
