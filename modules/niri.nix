{ inputs, ... }:
{
  programs.niri.enable = true;
  programs.niri.package = inputs.niri-flake.packages."x86_64-linux".niri-unstable;

  # DMS registers its own polkit agent; disable niri-flake's duplicate
  systemd.user.services.niri-flake-polkit.enable = false;

  programs.dank-material-shell.greeter.compositor = {
    name = "niri";
    customConfig = ''
      input {
        keyboard {
          xkb {
            layout "fr"
          }
        }
      }
      output "DP-1" {
        mode "3440x1440@144.000"
      }
    '';
  };
}
