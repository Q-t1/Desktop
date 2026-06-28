{ config, lib, inputs, ... }:
{
  imports = [ inputs.dms.homeModules.niri ];

  # DMS generates dms/*.kdl at runtime, but niri needs them to exist at startup.
  # Create empty stubs so niri can parse config on first boot; DMS overwrites them.
  home.activation.createNiriDmsStubs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.config/niri/dms"
    for f in alttab colors layout outputs wpblur; do
      if [ ! -f "$HOME/.config/niri/dms/$f.kdl" ]; then
        $DRY_RUN_CMD touch "$HOME/.config/niri/dms/$f.kdl"
      fi
    done
  '';

  programs.dank-material-shell.niri = {
    enableKeybinds = true;
    enableSpawn    = true;
    includes.filesToInclude = [
      "alttab"
      "colors"
      "layout"
      "outputs"
      "wpblur"
    ];
  };

  programs.niri.settings = {
      environment = {
        LIBVA_DRIVER_NAME            = "nvidia";
        GBM_BACKEND                  = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME    = "nvidia";
        NVD_BACKEND                  = "direct";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        XCURSOR_THEME                = "Bibata-Modern-Classic";
        XCURSOR_SIZE                 = "24";
      };

      cursor = {
        theme = "Bibata-Modern-Classic";
        size  = 24;
      };

      input = {
        keyboard.xkb.layout = "fr";
        focus-follows-mouse.max-scroll-amount = "0%";
      };

      outputs."DP-1" = {
        mode  = { width = 3440; height = 1440; refresh = 144.0; };
        scale = 1.2;
      };

      layout = {
        gaps        = 14;
        border.width = 2;
        preset-column-widths = [
          { proportion = 0.5; }
          { proportion = 0.667; }
          { proportion = 1.0; }
        ];
      };

      hotkey-overlay.skip-at-startup = true;

      animations = { };

      binds = with config.lib.niri.actions; {
        # Apps
        "Mod+T" = { action = spawn "ghostty"; };
        "Mod+F" = { action = spawn "firefox"; };

        # Window management
        "Mod+Q"       = { action = close-window; };
        "Mod+W"       = { action = toggle-window-floating; };
        "Mod+Shift+M" = { action = fullscreen-window; };

        # Focus — keyboard
        "Mod+Left"  = { action = focus-column-left; };
        "Mod+Right" = { action = focus-column-right; };
        "Mod+Up"    = { action = focus-window-up; };
        "Mod+Down"  = { action = focus-window-down; };

        # Move within layout
        "Mod+Shift+Left"  = { action = move-column-left; };
        "Mod+Shift+Right" = { action = move-column-right; };
        "Mod+Shift+Up"    = { action = move-window-up; };
        "Mod+Shift+Down"  = { action = move-window-down; };

        # Focus workspace by number
        "Mod+1" = { action = focus-workspace 1; };
        "Mod+2" = { action = focus-workspace 2; };
        "Mod+3" = { action = focus-workspace 3; };
        "Mod+4" = { action = focus-workspace 4; };
        "Mod+5" = { action = focus-workspace 5; };
        "Mod+6" = { action = focus-workspace 6; };
        "Mod+7" = { action = focus-workspace 7; };
        "Mod+8" = { action = focus-workspace 8; };
        "Mod+9" = { action = focus-workspace 9; };
        "Mod+0" = { action = focus-workspace 10; };

        # Move window to workspace by number (dot-notation to bypass lib.niri.actions)
        "Mod+Shift+1" = { action."move-window-to-workspace" = 1; };
        "Mod+Shift+2" = { action."move-window-to-workspace" = 2; };
        "Mod+Shift+3" = { action."move-window-to-workspace" = 3; };
        "Mod+Shift+4" = { action."move-window-to-workspace" = 4; };
        "Mod+Shift+5" = { action."move-window-to-workspace" = 5; };
        "Mod+Shift+6" = { action."move-window-to-workspace" = 6; };
        "Mod+Shift+7" = { action."move-window-to-workspace" = 7; };
        "Mod+Shift+8" = { action."move-window-to-workspace" = 8; };
        "Mod+Shift+9" = { action."move-window-to-workspace" = 9; };
        "Mod+Shift+0" = { action."move-window-to-workspace" = 10; };

        # Scroll — wheel scrolls columns; Ctrl+wheel scrolls workspaces
        "Mod+WheelScrollRight"     = { action = focus-column-right;    cooldown-ms = 150; };
        "Mod+WheelScrollLeft"      = { action = focus-column-left;     cooldown-ms = 150; };
        "Mod+WheelScrollDown"      = { action = focus-column-right;    cooldown-ms = 150; };
        "Mod+WheelScrollUp"        = { action = focus-column-left;     cooldown-ms = 150; };
        "Mod+Ctrl+WheelScrollDown" = { action = focus-workspace-down;  cooldown-ms = 150; };
        "Mod+Ctrl+WheelScrollUp"   = { action = focus-workspace-up;    cooldown-ms = 150; };

        # Cycle column width presets
        "Mod+R" = { action = switch-preset-column-width; };
      };
  };
}
