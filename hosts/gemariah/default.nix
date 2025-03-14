{ config, nixos-hardware, pkgs, secrets, thoughtfull, ... } : {
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };
  environment.systemPackages = [ pkgs.glances ];
  hardware = {
    acpilight.enable = true;
    bluetooth.enable = true;
    graphics.enable = true;
  };
  home-manager.users = {
    root.home.stateVersion = "24.11";
    technosophist = {
      home = {
        stateVersion = "24.11";
        file.".config/emacs/init.el".source = ./init.el;
        packages = with pkgs; [
          gimp
          google-chrome
          hugo
          inkscape
        ];
      };
      programs.emacs.extraPackages = epkgs: with epkgs; [
        tfl-gtd
        tfl-ol-obsidian
        tfl-org
        tfl-org-bullets
        tfl-org-capture
        tfl-org-faces
      ];
      services.syncthing.extraOptions = [
        "-gui-address=0.0.0.0:8384"
      ];
      thoughtfull = {
        clojure.enable = true;
        gnome-terminal.enable = true;
        javascript = {
          enable = true;
          nodejs-package = pkgs.nodejs_18;
        };
        services.syncthing-init.folders = {
          archive = {
            devices = [ "naarah" ];
            enable = true;
          };
          obsidian = {
            devices = [ "naarah" "phone" ];
            enable = true;
          };
          obsidian-work.enable = true;
          org = {
            devices = [ "naarah" "phone" ];
            enable = true;
          };
          org-work.enable = true;
          sync = {
            devices = [ "naarah" "phone" ];
            enable = true;
          };
        };
      };
      xfconf.settings.pointers."TPPS2_Elan_TrackPoint/Acceleration" = 6.5;
    };
  };
  imports = [
    ../../users/technosophist
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-x1
    secrets.nixosModules.gemariah
    thoughtfull.nixosModules.default
  ];
  networking = {
    domain = "thoughtfull.systems";
    firewall.allowedTCPPorts = [ 8384 ];
    hostName = "gemariah";
  };
  programs = {
    adb.enable = true;
    ssh.extraConfig = ''
      Host adoram.thoughtfull.systems adoram
      Hostname adoram.thoughtfull.systems
      User root

      Host naarah
      Hostname naarah.lan
      User root
    '';
  };
  security.acme.defaults.email = "technosophist@thoughtfull.systems";
  services = {
    displayManager.autoLogin = {
      enable = true;
      user = "technosophist";
    };
    netdata.enable = true;
    printing.drivers = [ pkgs.cups-brother-mfcl2750dw ];
    tlp.settings = {
      START_CHARGE_THRESH_BAT0 = 100;
      STOP_CHARGE_THRESH_BAT0 = 100;
    };
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
    deploy-keys = [
      { name = "adoram"; }
      { name = "nixos-secrets"; }
    ];
    desktop.enable = true;
    greek.enable = true;
    netdata.parent.host = "localhost";
    tunnels.adoram = {
      bindings = [
        {
          local.port = 19999;
          remote.port = 19999;
        }
      ];
      enable = true;
      host = "adoram.thoughtfull.systems";
      identity = "/etc/nixos/adoram-deploy-key";
    };
  };
  time.timeZone = "America/New_York";
  users.users = {
    root.openssh.authorizedKeys = config.users.users.technosophist.openssh.authorizedKeys;
    technosophist.extraGroups = [ "adbusers" "docker" ];
  };
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
  };
}
