{ config, lib, pkgs, ... }:
{
  # DMS generates dms/*.kdl at runtime, but niri needs them to exist at startup.
  # Create empty stubs so niri can parse config on first boot; DMS overwrites them.
  home.activation.createNiriDmsStubs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "$HOME/.config/niri/dms"
    for f in alttab binds colors layout outputs windowrules wpblur; do
      if [ ! -f "$HOME/.config/niri/dms/$f.kdl" ]; then
        $DRY_RUN_CMD touch "$HOME/.config/niri/dms/$f.kdl"
      fi
    done
  '';

  programs.dank-material-shell.niri = {
    # DMS keybinds arrive via the `dms/binds.kdl` include below, not by merging
    # them into the niri-flake config. Using enableKeybinds together with the
    # include mechanism is flagged as redundant, so keep only the include path.
    enableKeybinds = false;
    enableSpawn    = true;
    includes.filesToInclude = [
      "alttab"
      "binds"
      "colors"
      "layout"
      "outputs"
      "windowrules"
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
        DISPLAY                      = ":0";
      };

      cursor = {
        theme = "Bibata-Modern-Classic";
        size  = 24;
        hide-when-typing = true;
      };

      input = {
        keyboard.xkb.layout = "fr";
        focus-follows-mouse.max-scroll-amount = "0%";
      };

      # Ask GTK/Qt apps for server-side decorations, so every window gets the
      # same niri-drawn corners, focus ring and shadow instead of its own CSD.
      prefer-no-csd = true;

      outputs."DP-1" = {
        mode  = { width = 3440; height = 1440; refresh = 144.0; };
        scale = 1.2;
      };

      # Gaps, corner radius and border/focus-ring width are owned by DMS
      # (niriLayout*Override in dms.nix → dms/layout.kdl, which is included
      # after this file and wins); keep these in step so niri's own fallback
      # matches if that file is ever missing.
      layout = {
        gaps        = 12;
        border.width = 2;
        preset-column-widths = [
          { proportion = 0.5; }
          { proportion = 0.667; }
          { proportion = 1.0; }
        ];
      };

      hotkey-overlay.skip-at-startup = true;

      # Slightly softer than niri's defaults: critically damped springs (no
      # overshoot) with lower stiffness for movement, and longer expo easing
      # for windows appearing/disappearing.
      animations = {
        workspace-switch.kind.spring         = { damping-ratio = 1.0; stiffness = 900; epsilon = 0.0001; };
        horizontal-view-movement.kind.spring = { damping-ratio = 1.0; stiffness = 700; epsilon = 0.0001; };
        window-movement.kind.spring          = { damping-ratio = 1.0; stiffness = 700; epsilon = 0.0001; };
        window-resize.kind.spring            = { damping-ratio = 1.0; stiffness = 700; epsilon = 0.0001; };
        overview-open-close.kind.spring      = { damping-ratio = 1.0; stiffness = 800; epsilon = 0.0001; };
        window-open.kind.easing  = { duration-ms = 220; curve = "ease-out-expo"; };
        window-close.kind.easing = { duration-ms = 180; curve = "ease-out-quad"; };
      };

      # Workspaces float over DMS's blurred wallpaper (dms/wpblur.kdl) in the
      # overview; zoom out a little less than the default 0.5 on the ultrawide.
      overview.zoom = 0.55;

      # XWayland clients (via xwayland-satellite) don't get their fullscreen
      # requests honoured by niri, so force fullscreen at open time instead.
      window-rules = [
        {
          matches = [{ app-id = "^Unity$"; }];
          open-fullscreen = true;
        }

        # Steam games. Steam exports SDL_VIDEO_X11_WMCLASS=steam_app_<appid>,
        # so both native and Proton titles show up as "steam_app_1234".
        # gamescope-wrapped titles show up as "gamescope" instead.
        {
          matches = [
            { app-id = "(?i)^steam_app_[0-9]+$"; }
            { app-id = "(?i)^gamescope$"; }
          ];
          open-fullscreen = true;
        }

        # Big Picture shares the client's app-id; only the title tells them apart.
        {
          matches = [{ app-id = "(?i)^steam$"; title = "Big Picture"; }];
          open-fullscreen = true;
        }

        # Steam's helper windows shouldn't claim a tiling column.
        {
          matches = [
            { app-id = "(?i)^steam$"; title = "^Friends List$"; }
            { app-id = "(?i)^steam$"; title = "^Steam Settings$"; }
            { app-id = "(?i)^steam$"; title = "^Special Offers$"; }
            { app-id = "(?i)^steam$"; title = "^notificationtoasts_[0-9]+_desktop$"; }
          ];
          open-floating = true;
        }
      ];

      binds = with config.lib.niri.actions; {
        # Apps
        "Mod+T" = { action = spawn "ghostty"; };
        "Mod+F" = { action = spawn "firefox"; };

        # Screenshots. The Logitech keyboard's Fn+F8 doesn't emit F8 — it sends
        # the Windows snip chord Super+Shift+S, so bind that. Print is kept as a
        # second entry point for keyboards that have a real PrtSc key.
        # (dot-notation: the screenshot actions take named properties, so they
        # aren't exposed through lib.niri.actions)
        "Mod+Shift+S" = { action.screenshot = { }; };
        "Print"       = { action.screenshot = { }; };
        "Ctrl+Print"  = { action.screenshot-screen = { }; };
        "Alt+Print"   = { action.screenshot-window = { }; };

        # Window management
        "Mod+Q"       = { action = close-window; };
        "Mod+W"       = { action = toggle-window-floating; };
        "Mod+Shift+M" = { action = fullscreen-window; };
        "Mod+Shift+F" = { action = toggle-windowed-fullscreen; };

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

        # DankMaterialShell. Its own binds would arrive through `dms/binds.kdl`,
        # which DMS only fills from its Settings UI (enableKeybinds is false, see
        # above) — so the shell's entry points are bound here, over its IPC.
        "Mod+Space"   = { action = spawn "dms" "ipc" "call" "launcher" "toggle";      hotkey-overlay.title = "Application launcher"; };
        "Mod+V"       = { action = spawn "dms" "ipc" "call" "clipboard" "toggle";     hotkey-overlay.title = "Clipboard history"; };
        "Mod+N"       = { action = spawn "dms" "ipc" "call" "notifications" "toggle"; hotkey-overlay.title = "Notification center"; };
        "Mod+Comma"   = { action = spawn "dms" "ipc" "call" "settings" "toggle";      hotkey-overlay.title = "DMS settings"; };
        "Mod+X"       = { action = spawn "dms" "ipc" "call" "powermenu" "toggle";     hotkey-overlay.title = "Power menu"; };
        "Mod+M"       = { action = spawn "dms" "ipc" "call" "processlist" "toggle";   hotkey-overlay.title = "Process list"; };
        "Mod+P"       = { action = spawn "dms" "ipc" "call" "notepad" "toggle";       hotkey-overlay.title = "Notepad"; };
        "Mod+Alt+N"   = { action = spawn "dms" "ipc" "call" "night" "toggle";         hotkey-overlay.title = "Night mode"; allow-when-locked = true; };
        "Mod+Alt+L"   = { action = spawn "dms" "ipc" "call" "lock" "lock";            hotkey-overlay.title = "Lock screen"; };
        "Mod+F1"      = { action = spawn "dms" "ipc" "call" "keybinds" "toggle" "niri"; hotkey-overlay.title = "Keybind cheat sheet"; };
        "Mod+O"       = { action = toggle-overview; repeat = false; };

        # Volume / media through DMS, so they get its OSD.
        "XF86AudioRaiseVolume" = { action = spawn "dms" "ipc" "call" "audio" "increment" "3"; allow-when-locked = true; };
        "XF86AudioLowerVolume" = { action = spawn "dms" "ipc" "call" "audio" "decrement" "3"; allow-when-locked = true; };
        "XF86AudioMute"        = { action = spawn "dms" "ipc" "call" "audio" "mute";          allow-when-locked = true; };
        "XF86AudioMicMute"     = { action = spawn "dms" "ipc" "call" "audio" "micmute";       allow-when-locked = true; };
        "XF86AudioPlay"        = { action = spawn "dms" "ipc" "call" "mpris" "playPause";     allow-when-locked = true; };
        "XF86AudioNext"        = { action = spawn "dms" "ipc" "call" "mpris" "next";          allow-when-locked = true; };
        "XF86AudioPrev"        = { action = spawn "dms" "ipc" "call" "mpris" "previous";      allow-when-locked = true; };

        # Monitor brightness over DDC/CI (see modules/brightness.nix). DMS ships
        # these binds itself, but they arrive through `dms/binds.kdl`, which we
        # don't get since enableKeybinds is false — so drive its IPC directly.
        # The trailing "" is the device argument: empty means "every display".
        "XF86MonBrightnessUp" = {
          action = spawn "dms" "ipc" "call" "brightness" "increment" "5" "";
          allow-when-locked = true;
        };
        "XF86MonBrightnessDown" = {
          action = spawn "dms" "ipc" "call" "brightness" "decrement" "5" "";
          allow-when-locked = true;
        };
      };
  };

  home.packages = [ pkgs.xwayland-satellite ];

  systemd.user.services.xwayland-satellite = {
    Unit = {
      Description = "XWayland satellite for niri";
      PartOf      = [ "graphical-session.target" ];
      After       = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :0";
      Restart   = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
