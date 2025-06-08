{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.env.x11";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "X11";
    };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      xkb.layout = "us";
    };
  };
}
