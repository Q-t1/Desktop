{ pkgs, inputs, ... }:
{
  imports = [
    ../../modules/home/niri.nix
    ../../modules/home/dms.nix
    ../../modules/home/firefox.nix
    ../../modules/home/must-haves.nix
  ];

  home = {
    username = "qt1";
    homeDirectory = "/home/qt1";
    stateVersion = "26.05";
    packages = [ pkgs.deezer-desktop ];

    pointerCursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
}
