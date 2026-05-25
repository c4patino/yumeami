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

      media = {
        spotify = enabled;
      };

      metrics = {
        hyperfine = enabled;
        nvtop = enabled;
      };

      tools = {
        presenterm = enabled;
      };
    };

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
    "ssh/deploy-rs/private" = {
      path = "${user.home.directory}/.ssh/id_ed25519-deploy-rs";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
    "ssh/deploy-rs/public" = {
      path = "${user.home.directory}/.ssh/id_ed25519-deploy-rs.pub";
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
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
    "DP-4, 2560x1440@120, 0x0, 1"
    "DP-5, 2560x1440@120, -2560x0, 1"
    ", preferred, auto-left, 1"
  ];

  home.stateVersion = "25.11";
}
