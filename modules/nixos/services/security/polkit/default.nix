{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.security.polkit";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "polkit";
    };

  config = mkIf cfg.enable {
    security.polkit = enabled;
  };
}
