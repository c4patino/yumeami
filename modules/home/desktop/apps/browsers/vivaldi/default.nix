{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.browsers.vivaldi";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Vivaldi";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [vivaldi];
  };
}
