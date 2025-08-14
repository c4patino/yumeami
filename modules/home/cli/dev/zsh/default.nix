{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption optionalString;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.zsh";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "zsh";
    p10kEnable = mkEnableOption "enable powerlevel10k";
  };

  config = mkIf cfg.enable {
    home = {
      packages = mkIf cfg.p10kEnable (with pkgs; [zsh-powerlevel10k]);
      file = mkIf cfg.p10kEnable {
        ".p10k.zsh".source = inputs.dotfiles + "/.p10k.zsh";
      };
    };

    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        initContent = ''
          ${optionalString cfg.p10kEnable "source ~/.p10k.zsh"}
        '';

        shellAliases = {
          shutdown = "sudo shutdown";
          reboot = "sudo reboot";
          rsyncp = "rsync -P -ahvz";
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
          (mkIf cfg.p10kEnable {
            name = "powerlevel10k";
            src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
            file = "powerlevel10k.zsh-theme";
          })
        ];
      };

      carapace.enableZshIntegration = (getAttrByNamespace config "${namespace}.cli.dev.carapace").enable;
      direnv.enableZshIntegration = (getAttrByNamespace config "${namespace}.cli.dev.direnv").enable;
      fzf.enableZshIntegration = (getAttrByNamespace config "${namespace}.cli.dev.fzf").enable;
      kitty.shellIntegration.enableZshIntegration = (getAttrByNamespace config "${namespace}.desktop.apps.terminals.kitty").enable;
      starship.enableZshIntegration = (getAttrByNamespace config "${namespace}.cli.dev.starship").enable;
      yazi.enableZshIntegration = (getAttrByNamespace config "${namespace}.cli.media.yazi").enable;
      zoxide.enableZshIntegration = (getAttrByNamespace config "${namespace}.cli.dev.zoxide").enable;
    };
  };
}
