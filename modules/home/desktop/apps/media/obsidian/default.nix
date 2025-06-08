{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.media.obsidian";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Obsidian";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [obsidian];
  };
}
