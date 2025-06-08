{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.tools.obs";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "OBS Studio";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [obs-studio];
  };
}
