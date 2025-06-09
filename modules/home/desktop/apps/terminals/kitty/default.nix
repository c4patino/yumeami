{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.terminals.kitty";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Kitty";
  };

  config = {
    home.packages = with pkgs; [kitty.terminfo];

    programs.kitty = mkIf cfg.enable {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      font = {
        name = "MesloLGM Nerd Font Mono";
        size = 14;
      };
      themeFile = "tokyo_night_night";

      keybindings = {
        "ctrl+enter" = "new_window_with_cwd";
      };

      extraConfig = ''
        enabled_layouts grid, fat
      '';
    };
  };
}
