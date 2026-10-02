{ ... }:
let
  # DMS does not merge a bar entry with its defaults: a key missing from
  # `barConfigs` reads as undefined, not as the default. So start from the full
  # default bar of DMS 1.6 (quickshell/Common/settings/SettingsSpec.js) and only
  # override what differs.
  defaultBar = {
    id = "default";
    name = "Main Bar";
    enabled = true;
    position = 0; # top
    screenPreferences = [ "all" ];
    showOnLastDisplay = true;
    leftWidgets = [ ];
    centerWidgets = [ ];
    rightWidgets = [ ];
    spacing = 4;
    innerPadding = 4;
    barLengthPadding = 0;
    bottomGap = 0;
    attachToScreenEdge = false;
    transparency = 1.0;
    widgetTransparency = 1.0;
    squareCorners = false;
    noBackground = false;
    maximizeWidgetIcons = false;
    maximizeWidgetText = false;
    removeWidgetPadding = false;
    widgetPadding = 8;
    batteryColorMode = "theme";
    gothCornersEnabled = false;
    gothCornerRadiusOverride = false;
    gothCornerRadiusValue = 12;
    borderEnabled = false;
    borderColor = "surfaceText";
    borderOpacity = 1.0;
    borderThickness = 1;
    widgetOutlineEnabled = false;
    widgetOutlineColor = "primary";
    widgetOutlineOpacity = 1.0;
    widgetOutlineThickness = 1;
    fontScale = 1.0;
    iconScale = 1.0;
    autoHide = false;
    autoHideStrict = false;
    autoHideDelay = 250;
    showOnWindowsOpen = false;
    openOnOverview = false;
    visible = true;
    popupGapsAuto = true;
    popupGapsManual = 4;
    maximizeDetection = true;
    useOverlayLayer = false;
    scrollEnabled = true;
    scrollXBehavior = "column";
    scrollYBehavior = "workspace";
    shadowIntensity = 0;
    shadowOpacity = 60;
    shadowColorMode = "default";
    shadowCustomColor = "#000000";
    clickThrough = false;
    hoverPopouts = false;
    hoverPopoutDelay = 150;
  };
in
{
  programs.dank-material-shell = {
    enable = true;

    systemd.enable = false;

    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableClipboardPaste = true;

    # settings.json is a read-only store symlink, so this is the whole config:
    # every unlisted key stays at its DMS default, and a change made in the
    # Settings UI is only "unsaved" (DMS offers to copy the resulting JSON —
    # port the keys worth keeping here). Valid keys are the SPEC in
    # quickshell/Common/settings/SettingsSpec.js of the pinned DMS.
    settings = {
      # Already at the current schema, so DMS doesn't try to migrate (and write
      # back to) a file it can't write.
      configVersion = 18;

      # --- Theme -------------------------------------------------------------
      # Greyscale stock theme (picked in the Settings UI). It also drives niri's
      # focus ring (dms/colors.kdl), GTK/Qt, Firefox and the terminal. Note its
      # `primary` is pure #ffffff, so anything DMS fills with primary turns into
      # a glaring white block — see workspaceColorMode below. "dynamic" would
      # extract a Material You palette from the wallpaper instead, using
      # matugenScheme. (`theme`/`dynamicTheming` are not DMS keys.)
      currentThemeName = "monochrome";
      matugenScheme = "scheme-tonal-spot";
      # nvim colours belong to the CodIDE flake.
      matugenTemplateNeovim = false;

      # --- Typography --------------------------------------------------------
      # Both come from modules/fonts.nix; DMS's defaults (Inter Variable,
      # Fira Code) aren't installed and would fall back to whatever fontconfig
      # picks.
      fontFamily = "Geist";
      monoFontFamily = "JetBrainsMono Nerd Font";
      fontWeight = 400;

      # --- Motion ------------------------------------------------------------
      animationVariant = 2; # Dynamic
      motionEffect = 2; # Depth
      springBounce = 0; # Smooth — no overshoot
      enableRippleEffects = true;

      # --- Glass: blur + translucency ----------------------------------------
      # niri >= 26.04 implements ext-background-effect-v1, so the bar, popouts,
      # modals and notifications get a real backdrop blur.
      blurEnabled = true;
      blurForegroundLayers = true;
      # The 1px "blur border" rings every blurred surface, and around the
      # island's satellite pills it read as a pale halo against the wallpaper.
      blurBorderEnabled = false;
      blurLayerOutlineOpacity = 0.08;
      popupTransparency = 0.9;
      dockTransparency = 0.8;
      # Blurred copy of the wallpaper placed in niri's backdrop (dms/wpblur.kdl):
      # the overview floats workspaces over it instead of a flat colour.
      blurredWallpaperLayer = true;
      blurWallpaperOnOverview = true;

      # --- Depth -------------------------------------------------------------
      # Flat surfaces: no M3 elevation shadow under the island, popouts,
      # modals or notifications — separation comes from blur + borders.
      m3ElevationEnabled = false;
      modalDarkenBackground = true;

      # --- niri layout (dms/layout.kdl, which is included after hm.kdl) ------
      cornerRadius = 16;
      niriLayoutGapsOverride = 12;
      niriLayoutRadiusOverride = 14;
      niriLayoutBorderSize = 2;

      # --- Bar: Dank Island ----------------------------------------------------
      # `island = true` renders this bar as a Dank Island: a pill at the top
      # centre that morphs into media, notifications, launcher, control center
      # and OSD activities (it replaces centerWidgets), with leftWidgets and
      # rightWidgets floating as "satellites" at the screen edges.
      barConfigs = [
        (defaultBar // {
          island = true;
          islandTransparency = 0.85; # glass, over the blur
          # Same height and top edge as the satellite pills (30 logical px at
          # spacing 6). The 38px default stood taller than them and reached into
          # the window area.
          islandOuterGap = 6;
          islandCompactThickness = 30;
          islandSatellitesEnabled = true;
          islandSatellitePosition = "edges";
          islandHomeLayout = [
            { id = "media"; enabled = true; }
            { id = "clock"; enabled = true; }
            { id = "weather"; enabled = true; }
            { id = "status"; enabled = false; }
            { id = "volume"; enabled = false; }
            { id = "brightness"; enabled = false; }
            { id = "notifications"; enabled = true; }
          ];

          # No launcherButton: Mod+Space opens the launcher inside the island.
          leftWidgets = [ "workspaceSwitcher" "focusedWindow" ];
          centerWidgets = [ "music" "clock" "weather" ];
          rightWidgets = [
            "systemTray"
            "privacyIndicator"
            "idleInhibitor"
            "clipboard"
            "cpuUsage"
            "memUsage"
            "notificationButton"
            "controlCenterButton"
          ];
          spacing = 6;
          innerPadding = 6;
          barLengthPadding = 4;
          transparency = 0.72;
          widgetTransparency = 0.9;
          borderEnabled = true;
          borderOpacity = 0.08;
        })
      ];
      showBattery = false;
      controlCenterShowAudioPercent = true;

      # Workspace pills show the apps living on them, grouped by app.
      showWorkspaceApps = true;
      groupWorkspaceApps = true;
      maxWorkspaceIcons = 4;
      # The focused pill defaults to `primary`, which monochrome makes pure
      # white; a raised grey keeps it distinct without glaring.
      workspaceColorMode = "secondaryContainer";

      # Media widget tinted by the album art.
      mediaUseAlbumArtAccent = true;

      # --- Launcher ----------------------------------------------------------
      # Default launcher binds (Mod+Space) open the launcher as an activity
      # inside the island instead of a separate modal.
      launcherStyle = "island";
      dankLauncherV2Size = "medium";
      appLauncherViewMode = "grid";

      # --- Clock / locale ----------------------------------------------------
      clockFormat = "24h";
      firstDayOfWeek = 1; # Monday
      # Weather/location from IP geolocation (ip-api.com) instead of a fixed city.
      useAutoLocation = true;

      # --- Notifications & OSD -----------------------------------------------
      notificationShowTimeoutBar = true;
      notificationTimeoutNormal = 6000;
      osdAlwaysShowValue = true;
      osdMediaPlaybackEnabled = true;

      # The volume tick on every key press gets old fast; keep notification and
      # plug-in sounds.
      soundVolumeChanged = false;

      # --- Idle & lock -------------------------------------------------------
      # DMS's own idle service, which replaced hypridle (see
      # modules/home/session.nix): it fades the screen out over a grace period
      # before locking / blanking instead of cutting to it, and respects idle
      # inhibitors (video, games, the bar's idleInhibitor). Seconds; 0 = never.
      acLockTimeout = 300;
      acMonitorTimeout = 600;
      acPostLockMonitorTimeout = 60;
      fadeToLockEnabled = true;
      fadeToDpmsEnabled = true;
      lockBeforeSuspend = true;
      loginctlLockIntegration = true;

      lockScreenShowMediaPlayer = true;
      lockScreenShowWeather = true;

      # --- Power menu --------------------------------------------------------
      powerMenuGridLayout = true;
    };

    # NOTE: session.json (~/.local/state/DankMaterialShell/session.json) is intentionally
    # NOT managed here. DMS stores the live wallpaper (SessionData.wallpaperPath) and
    # light/dark toggle in that file; a read-only Nix symlink would blank the wallpaper on
    # every rebuild and stop the carousel from persisting your pick. Left writable so DMS
    # owns it.
  };
}
