{
  imports = [
    ./disk-config.nix
    ../../modules/audio.nix
    ../../modules/avatars.nix
    ../../modules/graphics.nix
    ../../modules/locale.nix
    ../../modules/networking.nix
    ../../modules/users.nix
    ../../modules/firefox.nix
    ../../modules/fonts.nix
    ../../modules/gaming.nix
  ];

  networking.hostName = "desktop-qt1";

  services.gvfs.enable = true;

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "qt1";
        email = "quentin.roccia@gmail.com";
      };
      core.autocrlf = "input";
      core.eol = "lf";
      push.autoSetupRemote = true;
      push.default = "current";
      init.defaultBranch = "main";
    };
  };

}
