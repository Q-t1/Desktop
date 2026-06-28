{ inputs, pkgs, ... }:
{
  imports = [ inputs.dms.homeModules.dank-material-shell ];

  programs.dank-material-shell = {
    enable = true;

    systemd.enable = false;

    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableClipboardPaste = true;

    settings = {
      theme = "dark";
      dynamicTheming = true;
    };

    session = {
      isLightMode = false;
    };

    plugins.wallpaperCarousel = {
      src = pkgs.fetchFromGitHub {
        owner = "motor-dev";
        repo = "wallpaperCarousel";
        rev = "bca1f457763d51c8001f8edcc89df3e619420163";
        hash = "sha256-/0t6ykbirNgSB2gY1wpq8jbntnuUgME+kLDfwjLhfRg=";
      };
    };
  };
}
