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
  security.acme = {
    defaults.email = "technosophist@thoughtfull.systems";
    certs."thoughtfull.systems" = {};
  };
  services = {
    forgejo = {
      enable = true;
      settings = {
        "git.timeout" = {
          MIGRATE = 3600;
        };
        server = {
          DOMAIN = "git.thoughtfull.systems";
          ROOT_URL = "https://git.thoughtfull.systems/";
        };
      };
    };
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
    woodpecker-agents.agents.naarah = {
      enable = true;
      environment = {
        WOODPECKER_BACKEND = "local";
      };
      path = with pkgs; [
        # Needed to clone repos
        git
        git-lfs
        woodpecker-plugin-git
        # Used by the runner as the default shell
        bash
        # Most likely to be used in pipeline definitions
        coreutils
      ];
    };
    woodpecker-server = {
      enable = true;
      environment = {
        WOODPECKER_ADMIN = "technosophist";
        WOODPECKER_HOST = "https://woodpecker.thoughtfull.systems";
        WOODPECKER_FORGEJO = "true";
        WOODPECKER_FORGEJO_URL = "https://git.thoughtfull.systems";
      };
    };
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
    tunnels = {
      adoram = {
        bindings = [
          {
            local.port = 22;
            remote = {
              address = "0.0.0.0";
              port = 22;
            };
          }
          {
            local.port = 8000;
            remote.port = 8000;
          }
          {
            local.port = 8001;
            remote.port = 8001;
          }
          {
            local.port = 8002;
            remote.port = 8002;
          }
          {
            local.port = 8003;
            remote.port = 8003;
          }
          {
            local.port = 8004;
            remote.port = 8004;
          }
        ];
        enable = true;
        host = "adoram.thoughtfull.systems";
        identity = "/etc/nixos/adoram-deploy-key";
        port = 1980;
        user = "root";
      };
    };
  };
  users.users.root.openssh.authorizedKeys = config.users.users.technosophist.openssh.authorizedKeys;
}
