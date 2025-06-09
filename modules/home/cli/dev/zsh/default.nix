{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.zsh";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "zsh";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [zsh-powerlevel10k];
      file.".p10k.zsh" = {
        source = ./p10k.zsh;
      };
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = "source ~/.p10k.zsh";

      shellAliases = {
        shutdown = "sudo shutdown";
        reboot = "sudo reboot";
      };

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      oh-my-zsh = {
        enable = true;
        plugins = ["sudo" "git" "gitignore" "web-search" "copypath" "jsontools"];
        theme = "robbyrussell";
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        }
      ];
    };
  };
}
