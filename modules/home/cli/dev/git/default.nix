{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) concatStringsSep mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.cli.dev.git";
  cfg = getAttrByNamespace config base;

  ignores = [
    ".devenv/"
    ".direnv/"
    ".git/"
    ".opencode/"
    ".pnpm-store/"
    ".venv/"

    ".env"
    ".env.local"
    ".envrc"
    "AGENTS.md"
  ];
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {
    programs = {
      git = {
        inherit ignores;

        enable = true;
        lfs = enabled;

        settings = {
          commit.gpgsign = true;
          core = {
            pager = "delta";
            editor = "nvim";
            fileMode = false;
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
          push.autoSetupRemote = true;
          user = {
            name = "C4 Patino";
            email = "c4patino@gmail.com";
            signingkey = "~/.ssh/id_ed25519.pub";
          };
        };

        includes = [
          {
            condition = "gitdir:~/Programming/";
            contents = {
              core.excludesFile =
                pkgs.writeText "gitignore-programming"
                (concatStringsSep "\n" (ignores ++ ["/openspec/"]) + "\n");
            };
          }
          {
            condition = "gitdir:~/dotfiles/";
            contents = {
              core.excludesFile =
                pkgs.writeText "gitignore-dotfiles"
                (concatStringsSep "\n" (ignores ++ ["/openspec/"]) + "\n");
            };
          }
          {
            condition = "gitdir:~/Programming/moo/";
            contents = {
              user = {
                name = "Ceferino Patino";
                email = "ceferino.patino@mutualofomaha.com";
                signingkey = "~/.ssh/id_ed25519-mutualofomaha.pub";
              };
            };
          }
        ];
      };

      gh.enable = true;
    };

    home.packages = with pkgs; [
      delta
      forgejo-cli
    ];
  };
}
