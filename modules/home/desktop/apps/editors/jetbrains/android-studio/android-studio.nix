{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.editors.jetbrains.android-studio";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Android Studio";
    };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [android-studio];

      file.".ideavimrc" = {
        source = ../.ideavimrc;
      };
    };
  };
}
