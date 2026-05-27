{
  description = "Thien-An's dotfiles — NixOS / home-manager";

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
  in {
    # ── Full NixOS on WSL2 ────────────────────────────────────────────────
    # nixos-rebuild switch --flake .#wsl
    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        nixos-wsl.nixosModules.wsl
        ./hosts/wsl/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs   = true;
          home-manager.useUserPackages = true;
          home-manager.users.thienan   = import ./home;
        }
      ];
    };

    # ── Standalone home-manager on existing Ubuntu WSL ────────────────────
    # home-manager switch --flake .#thienan
    homeConfigurations."thienan" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home ];
    };
  };
}
