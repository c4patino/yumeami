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
        "ctrl+shift+h" = "neighboring_window left";
        "ctrl+shift+j" = "neighboring_window bottom";
        "ctrl+shift+k" = "neighboring_window top";
        "ctrl+shift+l" = "neighboring_window right";

        "ctrl+t" = "new_tab_with_cwd";
        "ctrl+shift+t" = "new_tab";

        "ctrl+enter" = "new_window_with_cwd";
        "ctrl+shift+enter" = "new_window";

        "ctrl+shift+r" = "set_tab_title";

        "ctrl+shift+<" = "move_tab -1";
        "ctrl+shift+>" = "move_tab +1";
      };

      extraConfig = ''
        enabled_layouts grid, fat
      '';
    };
  };
}
