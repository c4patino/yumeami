{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.tools.mongodb-compass";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "MongoDB Compass";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [mongodb-compass];
  };
}
