{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) enabled getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.security.polkit";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "polkit";
  };

  config = mkIf cfg.enable {
    security.polkit = enabled;
  };
}
