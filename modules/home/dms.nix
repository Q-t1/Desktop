{ inputs, ... }:
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
  };
}
