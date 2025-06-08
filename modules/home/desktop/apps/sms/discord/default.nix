{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.sms.discord";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Discord";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [webcord-vencord];
  };
}
