{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.cli.dev.git";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        lfs = enabled;

        settings = {
          commit.gpgsign = true;
          core = {
            pager = "delta";
            editor = "nvim";
          };
          delta = {
            dark = true;
            hyperlinks = true;
            line-numbers = true;
            navigate = true;
            side-by-side = true;
          };
          diff.colorMoved = "zebra";
          fetch.prune = true;
          gpg.format = "ssh";
          init.defaultBranch = "main";
          interactive.diffFilter = "delta --color-only";
          maintenance.auto = true;
          merge.conflictStyle = "zdiff3";
          pull.rebase = true;
          user = {
            name = "C4 Patino";
            email = "c4patino@gmail.com";
            signingkey = "~/.ssh/id_ed25519.pub";
          };
        };

        ignores = [
          ".direnv"
          ".env"
          ".env.local"
          ".envrc"
          ".git"
          ".pnpm-store"
          ".venv"
          "AGENTS.md"
        ];
      };

      gh.enable = true;
    };

    home.packages = with pkgs; [
      delta
    ];
  };
}
