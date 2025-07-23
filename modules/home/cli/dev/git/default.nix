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
      userName = "C4 Patino";
      userEmail = "c4patino@gmail.com";

      extraConfig = {
        user.signingkey = "~/.ssh/id_ed25519.pub";
        init.defaultBranch = "main";
        pull.rebase = true;
        fetch.prune = true;

        maintenance.auto = true;
        core.editor = "nvim";
        commit.gpgsign = true;
        gpg.format = "ssh";
        diff.colorMoved = "zebra";
      };

      ignores = [
        # Add patterns to globally ignore here
        ".env"
        ".env.local"
        ".direnv"
        ".envrc"
        "AGENTS.md"
      ];
    };

    programs.gh = enabled;
  };
}
