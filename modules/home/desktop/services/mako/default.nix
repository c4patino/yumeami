{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.services.mako";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Mako";
    };

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
