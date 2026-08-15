{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];

  boot.kernelModules = [ "kvm-intel" ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.tpm2.enable = true;

  boot.initrd.luks.devices.cryptroot = {
    # Pin the root LUKS container by its header UUID, NOT by partlabel. This host has
    # two NVMe drives that share the partlabel "disk-disk1-luksroot", so the disko
    # default (/dev/disk/by-partlabel/…) resolves nondeterministically at boot and
    # frequently unlocks the wrong disk. by-uuid is globally unique, so unlock is
    # deterministic. This UUID is nvme1n1p2 (the drive holding pool/root).
    device = lib.mkForce "/dev/disk/by-uuid/8e7dc6dc-bd69-4632-84d3-b127051c0e54";
    allowDiscards = true;
    # TPM2 hardware binding only — no PCR policy so nixos-rebuild / lanzaboote key
    # re-enrollment never invalidates the token. Secure Boot provides boot integrity.
    # One-time enrollment (run once, then rebuild — stateful, cannot be declarative):
    #   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs= \
    #     /dev/disk/by-uuid/8e7dc6dc-bd69-4632-84d3-b127051c0e54
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  # /boot lives on the system drive's own ESP (nvme1n1p1). Pinned by GPT partition
  # UUID (by-partuuid) so it survives a vfat reformat and never collides with the
  # data drive. See docs/consolidate-to-single-drive.md for the migration runbook.
  fileSystems."/boot".device =
    lib.mkForce "/dev/disk/by-partuuid/74a0c4b2-4359-48a4-9286-8afd40ce6d5d";

  boot.initrd.services.lvm.enable = true;

  boot.loader.grub.enable = false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
    autoEnrollKeys = {
      enable = true;
      autoReboot = true;
    };
  };

  boot.initrd.systemd.enable = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "qt1" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
  };
  users.groups.greeter = { };

  services.greetd.settings.default_session.user = lib.mkDefault "greeter";

  programs.dank-material-shell.greeter = {
    enable = true;
    configHome = "/home/qt1";
  };

  services.openssh.enable = true;

  # Provides a dynamic loader at /lib64/ld-linux-x86-64.so.2 so prebuilt
  # non-Nix binaries (e.g. downloaded tools, some IDE/game binaries) run
  # without manual patchelf/FHS wrapping.
  programs.nix-ld.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.sbctl
    pkgs.tpm2-tools
    pkgs.tpm2-tss
    pkgs.curl
    pkgs.gitMinimal
    pkgs.bash
  ];

  system.stateVersion = "26.05";
}
