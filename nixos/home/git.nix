{ config, pkgs, lib, vars, ... }:
{
  programs.git = {
    enable    = true;
    userName  = vars.fullName;
    userEmail = vars.email;

    # delta as pager
    delta = {
      enable  = true;
      options = {
        navigate     = true;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
    };

    extraConfig = {
      init.defaultBranch     = "main";
      merge.conflictstyle    = "zdiff3";
      interactive.diffFilter = "delta --color-only";
    };

    # Credential helpers need duplicate `helper =` entries (first clears any
    # inherited global helper, second sets gh).  home-manager's attrs merge
    # would collapse them, so we use an includes file instead.
    includes = [
      {
        path = pkgs.writeText "git-credentials" ''
          [credential "https://github.com"]
            helper =
            helper = !${pkgs.gh}/bin/gh auth git-credential
          [credential "https://gist.github.com"]
            helper =
            helper = !${pkgs.gh}/bin/gh auth git-credential
        '';
      }
    ];
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      prompt       = "enabled";
      aliases      = {
        co = "pr checkout";
      };
    };
  };
}
