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
    allowDiscards = true;
    # Bind TPM2 unlock to PCR 0 (firmware) + PCR 7 (Secure Boot state).
    # After install run: systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
    crypttabExtraOpts = [ "tpm2-device=auto" "tpm2-pcrs=0+7" ];
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
