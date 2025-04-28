{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.zsh.enable = lib.mkEnableOption "zsh and plugins";

  config = lib.mkIf config.zsh.enable {
    home = {
      packages = with pkgs; [zsh-powerlevel10k];
      file.".p10k.zsh".source = inputs.dotfiles + "/p10k.zsh";
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
