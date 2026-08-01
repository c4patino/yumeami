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
          core = {
            pager = "delta";
            editor = "nvim";
            fileMode = false;
          };
          init.defaultBranch = "main";

          fetch.prune = true;
          pull.rebase = true;
          push.autoSetupRemote = true;

          maintenance.auto = true;
          rerere.enabled = true;

          commit.gpgsign = true;
          gpg.format = "ssh";

          delta = {
            dark = true;
            hyperlinks = true;
            line-numbers = true;
            navigate = true;
            side-by-side = true;
          };
          diff.colorMoved = "zebra";
          interactive.diffFilter = "delta --color-only";
          merge.conflictStyle = "zdiff3";

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
              core.sshCommand = "ssh -i ~/.ssh/id_ed25519-mutualofomaha -o IdentitiesOnly=yes";
              user = {
                name = "Ceferino Patino";
                email = "ceferino.patino@mutualofomaha.com";
                signingkey = "~/.ssh/id_ed25519-mutualofomaha.pub";
              };
            };
          }
        ];
      };
    };

    home.packages = with pkgs; [
      delta
    ];
  };
}
