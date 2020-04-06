{ config, pkgs, lib, options, ... }:
let
  myCustomLayout = pkgs.writeText "xkb-layout"
    ''
    keycode 38 = a A
    keycode 56 = x X
    keycode 54 = j J
    keycode 40 = e E
    keycode 26 = period greater
    keycode 41 = u U
    keycode 42 = i I
    keycode 43 = d D
    keycode 31 = c C
    keycode 44 = h H
    keycode 45 = t T
    keycode 46 = n N
    keycode 58 = m M
    keycode 57 = b B
    keycode 32 = r R
    keycode 33 = l L
    keycode 24 = apostrophe quotedbl
    keycode 27 = p P
    keycode 39 = o O
    keycode 28 = y Y
    keycode 30 = g G
    keycode 55 = k K
    keycode 25 = comma less
    keycode 53 = q Q
    keycode 29 = f F
    keycode 52 = semicolon colon
    keycode 59 = w W
    keycode 20 = bracketleft braceleft
    keycode 60 = v V
    keycode 61 = z Z
    keycode 47 = s S
    keycode 21 = bracketright braceright
    keycode 35 = equal plus
    keycode 34 = slash question
    keycode 48 = minus underscore
    keysym Alt_R = Super_R
    keysym Caps_lock = Ctrl_L
     '';
in
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
  services.xserver.libinput.tapping = false;
  services.xserver.displayManager.slim.enable = true;
  services.xserver.windowManager.session = lib.singleton {
    name = "exwm";
    start = ''
        /run/current-system/sw/bin/emacs --eval '(progn (server-start) (exwm-init))'
        '';
  };

  services.xserver.displayManager.sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${myCustomLayout}";

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
