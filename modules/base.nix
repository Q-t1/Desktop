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

  boot.initrd.luks.devices.cryptroot = {
    allowDiscards = true;
    preLVM = true;
    # TPM2 unlock via systemd crypttabExtraOpts
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

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

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "qt1" ];
  };

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

  environment.systemPackages = map lib.lowPrio [
    pkgs.sbctl
    pkgs.tpm2-tools
    pkgs.tpm-luks
    pkgs.curl
    pkgs.gitMinimal
    pkgs.bash
    pkgs.tpm2-tss
  ];

  system.stateVersion = "26.05";
}
