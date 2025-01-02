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
    hardware.url = "github:nixos/nixos-hardware/master";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:thoughtfull-systems/home-manager/release-24.11";
    };
    thoughtfull = {
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        unstable.follows = "unstable";
      };
      url = "github:thoughtfull-systems/nixfiles/nixos-24.11";
    };
    nixpkgs.url = "github:thoughtfull-systems/nixpkgs/nixos-24.11";
    secrets = {
      inputs = {
        agenix.follows = "agenix";
        darwin.follows = "darwin";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
      url = "git+ssh://git@github.com/thoughtfull-systems/nixos-secrets";
    };
    unstable.url = "github:thoughtfull-systems/nixpkgs/nixpkgs-unstable";
  };
  outputs = { hardware, nixpkgs, secrets, thoughtfull, ... }: {
    nixosConfigurations.gemariah = nixpkgs.lib.nixosSystem {
      modules = [
        ./gemariah
        hardware.nixosModules.lenovo-thinkpad-x1
        thoughtfull.nixosModules.default
        secrets.nixosModules.gemariah
      ];
      system = "x86_64-linux";
    };
  };
}
