{ inputs, pkgs, ... }:
{
  imports = [ inputs.dms.homeModules.dank-material-shell ];

  programs.dank-material-shell = {
    enable = true;

    systemd.enable = false;

    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableClipboardPaste = true;

    # Write plugin_settings.json. Without this the plugin below is symlinked into
    # ~/.config/DankMaterialShell/plugins but never flipped to enabled=true, so DMS
    # scans it and ignores it. Defaults to false unless a plugin declares non-empty
    # `settings`, which wallpaperCarousel does not — so set it explicitly.
    managePluginSettings = true;

    settings = {
      theme = "dark";
      dynamicTheming = true;
      # Weather/location from IP geolocation (ip-api.com) instead of a fixed city.
      useAutoLocation = true;
    };

    # NOTE: session.json (~/.local/state/DankMaterialShell/session.json) is intentionally
    # NOT managed here. DMS stores the live wallpaper (SessionData.wallpaperPath) and
    # light/dark toggle in that file; a read-only Nix symlink would blank the wallpaper on
    # every rebuild and stop the carousel from persisting your pick. Left writable so DMS
    # owns it. Dark mode still comes from settings.theme above.

    plugins.wallpaperCarousel = {
      src = pkgs.fetchFromGitHub {
        owner = "motor-dev";
        repo = "wallpaperCarousel";
        rev = "bca1f457763d51c8001f8edcc89df3e619420163";
        hash = "sha256-/0t6ykbirNgSB2gY1wpq8jbntnuUgME+kLDfwjLhfRg=";
      };
      # Folder the carousel browses. The chosen image is written to session.json
      # (writable, see note above). Create the folder and drop images in it.
      settings.wallpaperDirectory = "/home/qt1/Images/Wallpapers";
    };
  };

  # Ensure the wallpaper folder exists so the carousel has somewhere to look.
  home.file."Images/Wallpapers/.keep".text = "";
}
