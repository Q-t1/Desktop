{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    geist-font
    nerd-fonts.jetbrains-mono
    material-symbols
  ];

  environment.systemPackages = [ pkgs.papirus-icon-theme ];
}
