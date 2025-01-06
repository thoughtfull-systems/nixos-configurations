{ config, pkgs, ... } : {
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };
  home-manager.users.root.home.stateVersion = "24.11";
  imports = [
    ../../users/technosophist
    ./hardware-configuration.nix
  ];
  networking = {
    domain = "thoughtfull.systems";
    hostName = "gemariah";
  };
  security.acme.defaults.email = "technosophist@thoughtfull.systems";
  services = {
    displayManager.autoLogin = {
      enable = true;
      user = "technosophist";
    };
    printing.drivers = [ pkgs.cups-brother-mfcl2750dw ];
  };
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11";
  thoughtfull = {
    autoUpgrade = {
      flake = "github:thoughtfull-systems/nixos-configurations/main";
      inputs = [ "nixpkgs" ];
    };
    deploy-keys = [ { name = "nixos-secrets"; } ];
    desktop.enable = true;
    greek.enable = true;
  };
  time.timeZone = "America/New_York";
  users = {
    mutableUsers = false;
    users.root.openssh.authorizedKeys = config.users.users.technosophist.openssh.authorizedKeys;
  };
}
