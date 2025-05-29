{
  description = "NixOS configurations";
  inputs = {
    agenix = {
      inputs = {
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:ryantm/agenix/main";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:thoughtfull-nix/home-manager/release-25.05";
    };
    nixpkgs.url = "github:thoughtfull-nix/nixpkgs/nixos-25.05";
    secrets = {
      inputs = {
        agenix.follows = "agenix";
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
      url = "git+ssh://git@github.com/thoughtfull-systems/nixos-secrets";
    };
    thoughtfull = {
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        unstable.follows = "unstable";
      };
      url = "github:thoughtfull-systems/nixfiles/nixos-25.05";
    };
    unstable.url = "github:thoughtfull-nix/nixpkgs/nixos-unstable";
  };
  outputs = { nixos-hardware, nixpkgs, secrets, thoughtfull, ... }: {
    nixosConfigurations = {
      adoram = nixpkgs.lib.nixosSystem {
        modules = [ ./hosts/adoram ];
        specialArgs = {
          inherit nixos-hardware nixpkgs secrets thoughtfull;
        };
      };
      gemariah = nixpkgs.lib.nixosSystem {
        modules = [ ./hosts/gemariah ];
        specialArgs = {
          inherit nixos-hardware secrets thoughtfull;
        };
      };
      naarah = nixpkgs.lib.nixosSystem {
        modules = [ ./hosts/naarah ];
        specialArgs = {
          inherit nixos-hardware secrets thoughtfull;
        };
      };
    };
  };
}
