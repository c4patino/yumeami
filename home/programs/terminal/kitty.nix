{
  pkgs,
  lib,
  config,
  ...
}: {
  options.kitty.enable = lib.mkEnableOption "Kitty terminal emulator";

  config = {
    home.packages = with pkgs; [kitty.terminfo];

    programs.kitty = lib.mkIf config.kitty.enable {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      font = {
        name = "MesloLGM Nerd Font Mono";
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
