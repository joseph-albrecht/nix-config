{ config, pkgs, options, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.nixPath =
    options.nix.nixPath.default ++ 
    [ "nixpkgs-overlays=/etc/nixos/overlays-compat/" ];

  boot.loader.grub.enable  = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device  = "/dev/sda";

  networking.hostName = "geode"; 
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
    brave
    fish
    git
    iosevka
    myemacs
    ripgrep
    xcape
  ];

  #copied from https://github.com/nix-community/emacs-overlay/
  nixpkgs.overlays = [
    (self: super:
      {
        myemacs = let
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
                                    patches = [
                                      ./tramp-detect-wrapped-gvfsd-27.patch
                                      ./clean-env.patch
                                    ];
                                  });
      })
  ];
  
  
  services.xserver.enable = true;
  services.xserver.layout = "dvorak";
  services.xserver.xkbOptions = "ctrl:swapcaps";
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
