{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.games.prismlauncher";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "PrismLauncher";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [prismlauncher];
  };
}
