{ config, pkgs, ... }:
let
  wallpaperDirectory = "${config.home.homeDirectory}/Images/Wallpapers";
in
{
  # Wallpaper Carousel — a DMS daemon plugin: a fullscreen, skewed 3D carousel
  # over the wallpaper folder. Picking one goes through DMS's own wallpaper
  # service, so matugen re-themes the shell, niri and apps from it (see
  # dms.nix). The pick lands in the writable session.json, not here.
  programs.dank-material-shell = {
    # Write plugin_settings.json. Without this the plugin is symlinked into
    # ~/.config/DankMaterialShell/plugins but never flipped to enabled=true, so
    # DMS scans it and ignores it.
    managePluginSettings = true;

    plugins.wallpaperCarousel = {
      src = pkgs.fetchFromGitHub {
        owner = "motor-dev";
        repo = "wallpaperCarousel";
        rev = "bca1f457763d51c8001f8edcc89df3e619420163";
        hash = "sha256-/0t6ykbirNgSB2gY1wpq8jbntnuUgME+kLDfwjLhfRg=";
      };
      # Keys are the plugin's WallpaperCarouselSettings.qml; plugin_settings.json
      # is read-only, so its in-shell settings page can't save over these.
      settings = {
        inherit wallpaperDirectory;
        carouselMode = "infinite";
        # Tiles sized for the 3440x1440 @ 1.2 panel, corners matching the
        # shell's 16px radius.
        itemWidth = 360;
        itemHeight = 600;
        cornerRadius = 16;
        borderWidth = 2;
        selectedScale = 110;
        expandSelected = true;
        expandMultiplier = 160;
        # Dwell on a tile for a large preview.
        enableHoldExpand = true;
        holdExpandRatio = 45;
        holdDelay = 900;
        overlayOpacity = 70;
        cacheSize = 60;
      };
    };
  };

  programs.niri.settings.binds = {
    # Mod+W is toggle-window-floating, so the plugin README's bind moves over.
    # Arrows / Enter / Escape drive it once open.
    "Mod+Shift+W" = {
      action.spawn = [ "dms" "ipc" "call" "wallpaperCarousel" "toggle" ];
      hotkey-overlay.title = "Wallpaper carousel";
    };
  };

  # A daemon plugin has no bar widget or launcher entry of its own, so without
  # this the only way in is the bind above. Lists it in the DMS launcher.
  xdg.desktopEntries.wallpaper-carousel = {
    name = "Wallpaper Carousel";
    genericName = "Wallpaper picker";
    comment = "Browse and apply wallpapers";
    icon = "preferences-desktop-wallpaper";
    exec = "dms ipc call wallpaperCarousel toggle";
    terminal = false;
    categories = [ "Settings" "DesktopSettings" ];
  };

  # Ensure the wallpaper folder exists so the carousel has somewhere to look.
  home.file."Images/Wallpapers/.keep".text = "";
}
