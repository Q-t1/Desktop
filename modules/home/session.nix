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

  # Idle locking and screen blanking are DMS's own idle service, configured in
  # modules/home/dms.nix (ac*Timeout, fade-to-lock). It used to be hypridle,
  # which cut straight to the lock screen and couldn't fade.
}
