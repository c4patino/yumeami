{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.sms.zoom";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Zoom";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [zoom-us];
  };
}
