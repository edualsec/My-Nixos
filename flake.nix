# /etc/nixos/flake.nix
{
  description = "NixOS con MangoWM";

  # Cache binaria oficial: evita compilar Noctalia (C++) desde cero
  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser.url = "github:youwen5/zen-browser-flake";

    # Noctalia Shell fijado a v5.0.0-beta.8
    noctalia = {
      url = "github:noctalia-dev/noctalia/v5.0.0-beta.8";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MangoWM
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    mangowm,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit inputs;
      };

      modules = [
        ./configuration.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = {
            inherit inputs;
          };

          home-manager.users."d3rhund" = import ./home.nix;
        }
      ];
    };
  };
}