{
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;
  };

  # The NVIDIA driver doesn't release freed VRAM back into the pool, so niri's
  # memory usage grows without bound. Upstream's documented workaround is an
  # application profile that disables the free buffer pool for the compositor.
  # https://github.com/YaLTeR/niri/wiki/Nvidia
  #
  # nixpkgs owns the `nvidia-application-profiles-rc` file; the `.d` directory
  # beside it is free for our own rules.
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text =
    builtins.toJSON {
      rules = [
        {
          pattern = { feature = "procname"; matches = "niri"; };
          profile = "Limit Free Buffer Pool On Wayland Compositors";
        }
      ];
      profiles = [
        {
          name = "Limit Free Buffer Pool On Wayland Compositors";
          settings = [
            { key = "GLVidHeapReuseRatio"; value = 0; }
          ];
        }
      ];
    };
}
