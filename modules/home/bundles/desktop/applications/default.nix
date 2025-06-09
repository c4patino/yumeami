{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.bundles.desktop.applications";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "desktop application bundle";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      desktop = {
        apps = {
          browsers.vivaldi = enabled;

          media = {
            libreoffice = enabled;
            obsidian = enabled;
            spotify = enabled;
            zathura = enabled;
            zotero = enabled;
          };

          sms = {
            discord = enabled;
            slack = enabled;
            zoom = enabled;
          };

          terminals.kitty = enabled;
        };
      };
    };
  };
}
