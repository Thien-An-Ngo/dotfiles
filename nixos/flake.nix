{
  description = "dotfiles — NixOS / home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS-WSL: run full NixOS inside WSL2
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};
    vars   = import ./vars.nix;   # ← user-specific values; see vars.nix.example
  in {
    # ── Full NixOS on WSL2 ────────────────────────────────────────────────
    # nixos-rebuild switch --flake .#wsl
    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit vars; };
      modules = [
        nixos-wsl.nixosModules.wsl
        ./hosts/wsl/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs    = true;
          home-manager.useUserPackages  = true;
          home-manager.extraSpecialArgs = { inherit vars; };
          home-manager.users.${vars.username} = import ./home;
        }
      ];
    };

    # ── Standalone home-manager (existing Linux install) ──────────────────
    # home-manager switch --flake .#<username>
    homeConfigurations.${vars.username} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit vars; };
      modules = [ ./home ];
    };
  };
}
