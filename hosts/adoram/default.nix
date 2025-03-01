{ config, nixos-hardware, nixpkgs, pkgs, secrets, thoughtfull, ... }: {
  ec2.efi = true;
  environment.systemPackages = [ pkgs.glances ];
  home-manager.users.root = {
    home.stateVersion = "24.11";
    programs.tmux = {
      enable = true;
      extraConfig = ''
        set-option -g status-style fg=white,bg=cyan
      '';
    };
  };
  imports = [
    "${nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
    secrets.nixosModules.adoram
    thoughtfull.nixosModules.default
  ];
  networking = {
    domain = "thoughtfull.systems";
    firewall.allowedTCPPorts = [ 80 443 ];
    hostName = "adoram";
  };
  nixpkgs.hostPlatform = "aarch64-linux";
  programs.zsh.enable = true;
  security.acme = {
    defaults.email = "technosophist@thoughtfull.systems";
    certs."thoughtfull.systems" = {};
  };
  services = {
    netdata.enable = true;
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
  };
  swapDevices = [
    {
      device = "/swapfile";
    }
  ];
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
    stateVersion = "24.11"; # Did you read the comment?
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
    netdata.mode = "parent";
    nginx.proxies = {
      "bw.thoughtfull.systems".backend = "http://localhost:8000";
      "dashboard.thoughtfull.systems".backend = "http://localhost:19999";
      "social.thoughtfull.systems".backend = "http://localhost:8002";
      "webdav.thoughtfull.systems".backend = "http://localhost:8001";
    };
    systemd-notify-failure = {
      from = "technosophist@thoughtfull.systems";
      to = "technosophist@thoughtfull.systems";
    };
  };
  users.users.root.openssh.authorizedKeys.keyFiles = [ ../../users/technosophist/id_ed25519.pub ];
}
