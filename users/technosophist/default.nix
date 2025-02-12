{ pkgs, secrets, ... }: {
  home-manager.users.technosophist = {
    home.packages = with pkgs; [ proton-pass ];
    programs = {
    git = {
      enable = true;
      userEmail = "technosophist@thoughtfull.systems";
      userName = "technosophist";
    };
    zsh.enable = true;
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
