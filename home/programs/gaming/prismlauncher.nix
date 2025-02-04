{
  pkgs,
  lib,
  config,
  ...
}: {
  options.prismlauncher.enable = lib.mkEnableOption "Prism Launcher";

  config = lib.mkIf config.prismlauncher.enable {
    home.packages = with pkgs; [prismlauncher];
  };
}
