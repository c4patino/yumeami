{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.hyprland;
in {
  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      settings = {
        icons = true;
        max-icon-size = 64;

        max-visible = 3;
        default-timeout = 5000;
        ignore-timeout = true;

        anchor = "top-right";
        output = "DP-2";
      };
    };
  };
}
