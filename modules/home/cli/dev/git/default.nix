{
  config,
  lib,
  namespace,
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
    programs.git = {
      enable = true;
      lfs = enabled;

      settings = {
        user = {
          name = "C4 Patino";
          email = "c4patino@gmail.com";
          signingkey = "~/.ssh/id_ed25519.pub";
        };

        commit.gpgsign = true;
        core.editor = "nvim";
        diff.colorMoved = "zebra";
        fetch.prune = true;
        gpg.format = "ssh";
        init.defaultBranch = "main";
        maintenance.auto = true;
        pull.rebase = true;
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

    programs.gh = enabled;
  };
}
