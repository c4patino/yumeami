{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    prismlauncher.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable prism launcher";
    };
  };

  config = lib.mkIf config.prismlauncher.enable {
    home.packages = with pkgs; [
      prismlauncher
    ];
  };
}
