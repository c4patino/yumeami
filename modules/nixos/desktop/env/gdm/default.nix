{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.env.gdm";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "gdm";
    };

  config = mkIf cfg.enable {
    services.xserver.displayManager.gdm = {
      enable = true;
      autoSuspend = false;
    };
  };
}
