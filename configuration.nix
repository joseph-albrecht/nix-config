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

  hardware.enableAllFirmware = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  i18n = {
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };
  time.timeZone = "US/Eastern";

  environment.systemPackages = with pkgs; [
    emacs
    fish
    git
    iosevka
    ripgrep
  ];

  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.default = "i3";
  services.xserver.synaptics.enable = true;
  services.xserver.libinput.tapping = false;
  services.xserver.layout = "dvorak";
  services.xserver.desktopManager.plasma5.enable = true;
 
  desktopManager.xterm.enable = false;
 
  users.extraUsers.joey = {
    createHome = true;
    home = "/home/joey";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
