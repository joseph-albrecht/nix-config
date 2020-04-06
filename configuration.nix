{ config, pkgs, lib, options, ... }:

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
    defaultLocale = "en_US.UTF-8";
    consoleUseXkbConfig = true;
  };
  time.timeZone = "US/Eastern";

  environment.systemPackages = with pkgs; [
    brave
    ((pkgs.emacsPackagesGen pkgs.myemacs).emacsWithPackages (epkgs:
      (with epkgs;
        [
          pdf-tools
          exwm
        ])))
    fish
    git
    htop
    iosevka
    neovim
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
  services.xserver.xkbOptions = "ctrl:swapcaps, altwin:swap_ralt_rwin";
  services.xserver.libinput.tapping = false;
  services.xserver.displayManager.slim.enable = true;
  services.xserver.windowManager.session = lib.singleton {
    name = "exwm";
    start = ''
        /run/current-system/sw/bin/emacs --eval '(progn (server-start) (exwm-init))'
        '';
  };

  systemd.user.services."xcape" = {
    enable = true;
    description = "xcape to use CTRL as ESC when pressed alone";
    wantedBy = [ "default.target" ];
    serviceConfig.Type = "forking";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 2;
    serviceConfig.ExecStart = "${pkgs.xcape}/bin/xcape";
  }; 

  users.extraUsers.joey = {
    createHome = true;
    home = "/home/joey";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  system.stateVersion = "19.09";
}
