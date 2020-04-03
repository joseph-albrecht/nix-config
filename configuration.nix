{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable  = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device  = "/dev/sda";

  networking.hostName = "mymachine"; 
  networking.networkmanager.enable = true;

  services.xserver = {
    libinput.enable = true;
    synaptics.enable = false;

    config = ''
      Section "InputClass"
        Identifier     "Enable libinput for TrackPoint"
        MatchIsPointer "on"
        Driver         "libinput"
      EndSection
    '';
  };

  i18n = {
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };
  time.timeZone = "US/Eastern";

  environment.systemPackages = with pkgs; [
    emacsGit
    fish
    git
    iosevka
    ripgrep
  ];

  
  #copied from https://github.com/nix-community/emacs-overlay/
  nixpkgs.overlays = [
    (self: super: 
      emacsGit = let
        repoMeta = super.lib.importJSON ./emacs-emacs-27.json;
      in (self.emacs.override { srcRepo = true; }).overrideAttrs(old: {
                                  name = "emacs-git-${repoMeta.version}";
                                  inherit (repoMeta) version;
                                  src = super.fetchFromGitHub {
                                    owner = "emacs-mirror";
                                    repo = "emacs";
                                    inherit (repoMeta) sha256 rev;
                                  };
                                  buildInputs = old.buildInputs ++ [ super.jansson ];
                                });
    )]
    
    
  services.xserver.enable = true;
  services.xserver.layout = "dvorak";
  services.xserver.libinput.tapping = false;
  services.xserver.desktopManager.plasma5.enable = true;
  
  users.extraUsers.joey = {
    createHome = true;
    home = "/home/joey";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  system.stateVersion = "19.09";
}
