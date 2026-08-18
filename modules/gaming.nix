{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    # Make gamescope usable from Steam launch options ("gamescope -- %command%").
    gamescopeSession.enable = true;
  };

  # capSysNice must stay off: the CAP_SYS_NICE security wrapper can't acquire
  # its capabilities inside Steam's FHS env, so "gamescope -- %command%" launch
  # options abort before the game starts (nixpkgs#217119).
  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };

  programs.gamemode.enable = true;

  hardware.graphics.enable32Bit = true;

  programs.xwayland.enable = true;
}
