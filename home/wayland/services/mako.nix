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
      icons = true;

      maxIconSize = 64;
      maxVisible = 3;
      defaultTimeout = 5000;
      ignoreTimeout = true;
      anchor = "top-right";
      output = "DP-2";
    };
  };
}
