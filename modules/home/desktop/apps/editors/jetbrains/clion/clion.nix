{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.editors.jetbrains.clion";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "CLion";
    };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.clion];

      file.".ideavimrc" = {
        source = ../.ideavimrc;
      };
    };
  };
}
