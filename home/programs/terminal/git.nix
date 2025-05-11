{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.git;
in {
  options.git.enable = mkEnableOption "git, git-lfs, and gh-cli";

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
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

    programs.gh = {
      enable = true;
      extensions = with pkgs; [gh-copilot];
    };
  };
}
