{ pkgs, inputs, ... }:
{
  imports = [
    ../../modules/home/niri.nix
    ../../modules/home/dms.nix
    ../../modules/home/firefox.nix
    ../../modules/home/session.nix
  ];

  home = {
    stateVersion = "26.05";
    packages = [ pkgs.deezer-desktop pkgs.unityhub ];

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
