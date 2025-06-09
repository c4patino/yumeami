{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.bundles.desktop.applications";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
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
