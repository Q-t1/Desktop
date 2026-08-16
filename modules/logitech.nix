{ ... }:
{
  # Solaar — driver/config UI for Logitech Unifying & Bolt devices. Enabling it
  # also turns on `hardware.logitech.wireless` (mkDefault), whose udev rules are
  # what let a non-root user talk to the receiver's HID++ endpoint; without them
  # Solaar sees the devices but can't read battery or change any setting.
  programs.solaar = {
    enable = true;

    # Run Solaar as a user systemd service so the tray agent is up for the whole
    # graphical session, rather than only while a window is open. Started
    # hidden — open it from the tray.
    userService = {
      enable = true;
      window = "hide";
    };
  };
}
