{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.editors.jetbrains.rider";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Rider";
    };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.rider];

      file.".ideavimrc" = {
        source = ../.ideavimrc;
      };
    };
  };
}
