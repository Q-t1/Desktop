{ pkgs, ... }:
{
  # Polkit authentication agent
  home.packages = [ pkgs.lxqt.lxqt-policykit ];
  systemd.user.services.lxqt-policykit-agent = {
    Unit = {
      Description = "LXQt Polkit Authentication Agent";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Idle daemon — lock after 5 min, screen off after 8 min
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd            = "dms ipc call lock lock";
        before_sleep_cmd    = "dms ipc call lock lock";
        ignore_dbus_inhibit = false;
      };
      listener = [
        {
          timeout    = 300;
          on-timeout = "dms ipc call lock lock";
        }
        {
          timeout    = 480;
          on-timeout = "niri msg action power-off-monitors";
        }
      ];
    };
  };
}
