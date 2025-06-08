{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.dev.git";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
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
    };

    programs.gh = enabled;
  };
}
