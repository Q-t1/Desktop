{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    geist-font
    jetbrains-mono
    material-symbols
  ];

  environment.systemPackages = [ pkgs.papirus-icon-theme ];
}
