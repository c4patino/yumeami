{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.media.libreoffice";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "LibreOffice";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-qt
      hunspell
      hunspellDicts.en_US
    ];
  };
}
