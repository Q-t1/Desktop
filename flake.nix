# Everything dedicated to the `desktop` host (hardware, disks, Secure Boot,
# niri + DankMaterialShell, gaming, its two user accounts).
#
# This flake carries NO `nixosConfigurations`: the host *profile* lives in the
# devSystem flake (github:Q-t1/devSystem, `config/profiles/desktop/`), which
# consumes the two modules below. See README.md.
{
  description = "Qt1 desktop host configuration (consumed by the devSystem flake)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "git+https://github.com/nix-community/lanzaboote?rev=001e560fffc8f0235e9db20ebeb4ccde0ade1caf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Only `homeModules` of home-manager are referenced here (the consumer wires
    # home-manager itself), but the input is kept so a consumer can `follows` it
    # and keep one home-manager per host.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # The greetd login screen. It used to be `dms.nixosModules.greeter`
    # (`programs.dank-material-shell.greeter`); DankMaterialShell split it out
    # into its own repo, and that module is now a stub that only warns. The
    # options are the same, under `programs.dms-greeter`.
    dank-greeter = {
      url = "github:AvengeMedia/dank-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, disko, lanzaboote, dms, dank-greeter, niri-flake, ... }:
    let
      # Home Manager config for a human on this host. Pulled in by the consumer
      # for its primary user, and by the NixOS module below for `cecile` (whom
      # the consumer knows nothing about).
      #
      # The flake-level inputs it needs are imported here rather than read from
      # an `inputs` specialArg, so nothing under modules/ assumes the consumer
      # passes one. `programs.niri.settings` comes from niri-flake's own home
      # module, which its NixOS module injects into `home-manager.sharedModules`.
      homeModule = {
        imports = [
          dms.homeModules.dank-material-shell
          dms.homeModules.niri
          ./hosts/desktop/home.nix
        ];
      };

      nixosModule = {
        imports = [
          disko.nixosModules.disko
          lanzaboote.nixosModules.lanzaboote
          dms.nixosModules.dank-material-shell
          dank-greeter.nixosModules.default
          niri-flake.nixosModules.niri

          ./modules/base.nix
          ./modules/niri.nix
          ./hosts/desktop

          # Second account on this machine. The consumer only wires Home Manager
          # for its own primary user, so cecile's is declared here — this module
          # is the only place that knows she exists. Needs the consumer to have
          # imported `home-manager.nixosModules.home-manager`, which both
          # callers do.
          {
            home-manager.users.cecile = {
              imports = [ homeModule ];
              home.stateVersion = "26.05";
            };
          }
        ];
      };
    in
    {
      # `default` for the consumer's import; the host-named aliases read better
      # at a call site that imports several flakes.
      nixosModules = {
        default = nixosModule;
        desktop = nixosModule;
      };

      homeModules = {
        default = homeModule;
        desktop = homeModule;
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    };
}
