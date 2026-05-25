{
  config,
  host,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib.${namespace}) enabled;
in {
  imports = [./stylix.nix];

  ${namespace} = {
    bundles = {
      common = enabled;

      desktop = {
        enable = true;
        applications = enabled;
      };

      development = enabled;
      shell = enabled;
    };

    cli = {
      access = {
        bitwarden = enabled;
      };

      dev = {
        leetcode = enabled;
      };

      metrics = {
        hyperfine = enabled;
      };

      tools = {
        presenterm = enabled;
      };
    };

    desktop.services.brightnessctl = enabled;

    cli.dev.neovim.variant = "full";
  };

  programs = {
    kitty.font.size = 14;

    ssh.matchBlocks = {
      "github-mutual.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519-mutualofomaha";
        identitiesOnly = true;
      };
    };
  };

  sops.secrets = let
    inherit (config.snowfallorg) user;
  in {
    "ssh/ceferino.patino@mutualofomaha/private" = {
      path = "${user.home.directory}/.ssh/id_ed25519-mutualofomaha";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
    "ssh/ceferino.patino@mutualofomaha/public" = {
      path = "${user.home.directory}/.ssh/id_ed25519-mutualofomaha.pub";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
  };

  wayland.windowManager.hyprland.settings.monitor = [
    "eDP-1, 2880x1800@60, 0x0, 1.5"
    ", preferred, auto-right, 1"
  ];

  home.stateVersion = "25.11";
}
