{ config, pkgs, ... }: {
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
  hardware.raspberry-pi."4".poe-hat.enable = true;
  home-manager.users = {
    technosophist = {
      home.stateVersion = "23.11";
      services.syncthing.extraOptions = [
        "-gui-address=0.0.0.0:8384"
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
        obsidian-work.enable = true;
        org = {
          devices = [ "gemariah" "phone" ];
          enable = true;
        };
        org-work.enable = true;
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
  ];
  networking = {
    domain = "thoughtfull.systems";
    hostName = "naarah";
    interfaces.end0.useDHCP = true;
  };
  programs.zsh.enable = true;
  security.acme = {
    defaults.email = "technosophist@thoughtfull.systems";
    certs."thoughtfull.systems" = {};
  };
  services = {
    gotosocial.enable = true;
    nginx = {
      virtualHosts = {
        "thoughtfull.systems" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            location /.well-known/webfinger {
              rewrite ^.*$ https://social.thoughtfull.systems/.well-known/webfinger permanent;
            }

            location /.well-known/host-meta {
              rewrite ^.*$ https://social.thoughtfull.systems/.well-known/host-meta permanent;
            }

            location /.well-known/nodeinfo {
              rewrite ^.*$ https://social.thoughtfull.systems/.well-known/nodeinfo permanent;
            }

            location / {
              rewrite ^.*$ $scheme://www.thoughtfull.systems$request_uri? permanent;
            }
          '';
        };
      };
      enable = true;
    };
    nullmailer.config.adminaddr = "technosophist@thoughtfull.systems";
    openssh.enable = true;
    vaultwarden.enable = true;
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
      { name = "nixfiles"; }
      { name = "nixos-secrets"; }
    ];
    notify-reboot = {
      from = "technosophist@thoughtfull.systems";
      to = "technosophist@thoughtfull.systems";
    };
    nginx.proxies = {
      "bw.thoughtfull.systems".backend = "http://localhost:8000";
      "social.thoughtfull.systems" = {
        backend = "http://localhost:8002";
      };
      "webdav.thoughtfull.systems".backend = "http://localhost:8001";
    };
    restic = {
      exclude = [
        "/var/lib/syncthing/archive/.stversions"
        "/var/lib/syncthing/obsidian/.stversions"
        "/var/lib/syncthing/org/.stversions"
        "/var/lib/syncthing/sync/.stversions"
      ];
      paths = [
        "/var/lib/syncthing/archive"
        "/var/lib/syncthing/obsidian"
        "/var/lib/syncthing/org"
        "/var/lib/syncthing/sync"
      ];
      s3Bucket = "thoughtfull-systems-restic";
    };
    systemd-notify-failure = {
      from = "technosophist@thoughtfull.systems";
      to = "technosophist@thoughtfull.systems";
    };
  };
  users.users.root.openssh.authorizedKeys = config.users.users.technosophist.openssh.authorizedKeys;
}
