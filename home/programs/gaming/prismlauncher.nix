{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.prismlauncher;
in {
  options.prismlauncher.enable = mkEnableOption "Prism Launcher";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [prismlauncher];
  };
}
