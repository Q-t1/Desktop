{ pkgs, ... }:
{
  # A desktop has no internal panel backlight (/sys/class/backlight is empty),
  # so brightness has to be sent to the monitor over DDC/CI — a control channel
  # that rides the I2C bus of the display connector. Without the i2c-dev module
  # there are no /dev/i2c-* nodes at all, DMS finds no DDC display, and its
  # brightness control silently falls back to whatever LED-class device it can
  # find (here: the rtw88 WiFi card's LED, which explains the no-op slider).
  #
  # This also creates the "i2c" group and installs a udev rule tagging the nodes
  # with uaccess, so the locally logged-in user gets them via their seat.
  hardware.i2c.enable = true;

  # DMS speaks DDC/CI itself and does not shell out to ddcutil, but `ddcutil
  # detect` is the tool that tells a monitor/cable problem apart from a
  # permissions one — keep it around for diagnosing.
  #
  # If DDC ends up flaky on the NVIDIA card, the usual fix is forcing the
  # driver's software I2C implementation:
  #   boot.extraModprobeConfig = ''
  #     options nvidia NVreg_RegistryDwords="RMUseSwI2c=0x01;RMI2cSpeed=100"
  #   '';
  environment.systemPackages = [ pkgs.ddcutil ];
}
