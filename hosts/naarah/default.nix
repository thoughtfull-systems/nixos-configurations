{ config, nixos-hardware, inputs, pkgs, secrets, thoughtfull, ... }: {
  boot = {
    initrd = {
      availableKernelModules = [
        "pcie_brcmstb"      # required for the pcie bus to work
        "reset-raspberrypi" # required for vl805 firmware to load
        "usb_storage"
        "usbhid"
        "vc4"
      ];
      luks.devices.secure = {
        device = "/dev/disk/by-uuid/e351e043-c906-4d91-9451-84859888cced";
        preLVM = true;
      };
      network = {
        enable = true;
        ssh.enable = true;
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
  environment.systemPackages = [ pkgs.glances ];
  hardware.raspberry-pi."4".poe-hat.enable = true;
  home-manager.users = {
    technosophist = {
      home.stateVersion = "23.11";
      services.syncthing.extraOptions = [
        "--gui-address=0.0.0.0:8384"
      ];
      thoughtfull.services.syncthing-init.folders = {
        archive = {
          devices = [ "gemariah" ];
          enable = true;
        };
        obsidian = {
          devices = [ "gemariah" "phone" ];
          enable = true;
        };
        obsidian-work.enable = false;
        org = {
          devices = [ "gemariah" "phone" ];
          enable = true;
        };
        org-work.enable = false;
        sync = {
          devices = [ "gemariah" "phone" ];
          enable = true;
        };
      };
    };
    root = {
      home.stateVersion = "23.11";
      programs.tmux = {
        enable = true;
        extraConfig = ''
          set-option -g status-style fg=white,bg=cyan
        '';
      };
    };
  };
  imports = [
    ../../users/technosophist
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    secrets.nixosModules.naarah
    thoughtfull.nixosModules.default
  ];
  networking = {
    domain = "thoughtfull.systems";
    firewall.allowedTCPPorts = [ 8384 ];
    hostName = "naarah";
    interfaces.end0.useDHCP = true;
  };
  programs.zsh.enable = true;
  services = {
    gotosocial.enable = true;
    # netdata.enable = true;
    nullmailer.config.adminaddr = "technosophist@thoughtfull.systems";
    openssh.enable = true;
    webdav.enable = true;
  };
  system = {
    autoUpgrade.flags = [
      "--override-input secrets git+ssh://git@nixos-secrets.github.com/thoughtfull-systems/nixos-secrets"
    ];
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "23.05"; # Did you read the comment?
  };
  thoughtfull = {
    autoUpgrade = {
      flake = "github:thoughtfull-systems/nixos-configurations/main";
      inputs = [ "nixpkgs" ];
    };
    deploy-keys = [
      { name = "adoram"; }
      { name = "nixfiles"; }
      { name = "nixos-secrets"; }
    ];
    netdata.parent.host = "localhost";
    notify-reboot = {
      from = "technosophist@thoughtfull.systems";
      to = "technosophist@thoughtfull.systems";
    };
    restic = {
      exclude = [
        "/var/lib/syncthing/archive/.stversions"
        "/var/lib/syncthing/obsidian/.stversions"
        "/var/lib/syncthing/org/.stversions"
        "/var/lib/syncthing/sync/.stversions"
        "/home/technosophist/archive/.stversions"
        "/home/technosophist/obsidian/.stversions"
        "/home/technosophist/org/.stversions"
        "/home/technosophist/sync/.stversions"
      ];
      paths = [
        "/var/lib/syncthing/archive"
        "/var/lib/syncthing/obsidian"
        "/var/lib/syncthing/org"
        "/var/lib/syncthing/sync"
        "/home/technosophist/archive"
        "/home/technosophist/obsidian"
        "/home/technosophist/org"
        "/home/technosophist/sync"
      ];
      s3Bucket = "thoughtfull-systems-restic";
    };
    systemd-notify-failure = {
      from = "technosophist@thoughtfull.systems";
      to = "technosophist@thoughtfull.systems";
    };
    tunnels.adoram = {
      bindings = [
        {
          reverse = true;
          local.port = 8000;
          remote.port = 8000;
        }
        {
          reverse = true;
          local.port = 8001;
          remote.port = 8001;
        }
        {
          reverse = true;
          local.port = 8002;
          remote.port = 8002;
        }
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
  users.users.root.openssh.authorizedKeys = config.users.users.technosophist.openssh.authorizedKeys;
}
