{ inputs, pkgs, ... }:
{
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri;

  # DMS registers its own polkit agent; disable niri-flake's duplicate
  systemd.user.services.niri-flake-polkit.enable = false;

  programs.dank-material-shell.greeter.compositor = {
    name = "niri";
    customConfig = ''
      hotkey-overlay {
        skip-at-startup
      }
      input {
        keyboard {
          xkb {
            layout "fr"
          }
        }
      }
      output "DP-1" {
        mode "3440x1440@144.000"
        scale 1.2
      }
    '';
  };
}
