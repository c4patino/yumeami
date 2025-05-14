{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.kitty;
in {
  options.kitty.enable = mkEnableOption "Kitty terminal emulator";

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
