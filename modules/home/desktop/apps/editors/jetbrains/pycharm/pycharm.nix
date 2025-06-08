{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.editors.jetbrains.pycharm";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "PyCharm";
    };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [jetbrains.pycharm-professional];

      file.".ideavimrc" = {
        source = ../.ideavimrc;
      };
    };
  };
}
