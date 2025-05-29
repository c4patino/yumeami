{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.hyprland;
in {
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      eww
      playerctl
      imagemagick
    ];

    home.file.".assets/" = {
      source = inputs.dotfiles + "/assets";
      recursive = true;
    };

    programs.eww = {
      enable = true;
      configDir = ./config;
    };
  };
}
