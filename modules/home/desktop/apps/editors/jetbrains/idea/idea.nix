{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.editors.jetbrains.idea";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Idea";
    };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.idea-ultimate];

      file.".ideavimrc" = {
        source = ../.ideavimrc;
      };
    };
  };
}
