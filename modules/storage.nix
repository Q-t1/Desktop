{ ... }:
{
  # Secondary 931 GB drive (formerly nvme0n1, a stale duplicate install) wiped and
  # repurposed for games / large data. The partition + ext4 filesystem are created
  # once by hand (labelled "games" — see docs/consolidate-to-single-drive.md); the
  # mount below is declarative and matched by filesystem label, not device path.
  #
  # nofail + short device-timeout: a missing or failed data drive must never block
  # boot of the encrypted system.
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-label/games";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };

  # Give the primary user ownership of the mountpoint.
  # /mnt/games/shared is writable by everyone; the sticky bit (1777, like /tmp)
  # stops users from deleting each other's files.
  systemd.tmpfiles.rules = [
    "d /mnt/games 0755 qt1 users - -"
    "d /mnt/games/shared 1777 root root - -"
  ];
}
