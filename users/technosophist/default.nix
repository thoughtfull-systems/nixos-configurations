{ config, lib, pkgs, secrets, ... }: {
  home-manager.users.technosophist = {
    home.packages = lib.mkIf config.thoughtfull.desktop.enable (with pkgs; [
      ctmg
      paperkey
      proton-pass
      qrencode
    ]);
    programs = {
      gpg = {
        enable = true;
        scdaemonSettings = {
          disable-ccid = true;
        };
      };
      git = {
        enable = true;
        userEmail = "technosophist@thoughtfull.systems";
        userName = "technosophist";
        extraConfig = {
          user = {
            signingkey = "DF2034C6";
          };
        };
      };
      zsh.enable = true;
    };
    thoughtfull = {
      aider.enable = true;
      clojure.clj-kondo-package = pkgs.unstable.clj-kondo;
      mcp.enable = true;
      rust.enable = true;
    };
  };
  users.users.technosophist = {
    description = "technosophist";
    extraGroups = [ "networkmanager" "video" "wheel" ];
    group = "users";
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [ ./id_ed25519.pub ];
    shell = pkgs.zsh;
    uid = 1000;
  };
}
