{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.terminals.kitty";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
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
