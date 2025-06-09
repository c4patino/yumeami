{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.editors.jetbrains.android-studio";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
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
