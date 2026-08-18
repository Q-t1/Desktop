{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    # Make gamescope usable from Steam launch options ("gamescope -- %command%").
    gamescopeSession.enable = true;
  };

  # capSysNice lets gamescope raise its scheduling priority for smoother frames.
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.gamemode.enable = true;

  hardware.graphics.enable32Bit = true;

  programs.xwayland.enable = true;
}
