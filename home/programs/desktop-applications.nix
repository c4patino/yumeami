{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config;
in {
  options = {
    fiji.enable = mkEnableOption "Fiji";
    libreoffice.enable = mkEnableOption "LibreOffice";
    mongodb-compass.enable = mkEnableOption "MongoDB Compass";
    obs.enable = mkEnableOption "OBS Studio";
    obsidian.enable = mkEnableOption "Obsidian";
    postman.enable = mkEnableOption "Postman";
    sms.enable = mkEnableOption "SMS applications";
    zotero.enable = mkEnableOption "Zotero";
  };

  config = {
    home = {
      packages = with pkgs; [
        (mkIf cfg.fiji.enable fiji)
        (mkIf cfg.fiji.enable gtk3)

        (mkIf cfg.libreoffice.enable libreoffice-qt)
        (mkIf cfg.libreoffice.enable hunspell)
        (mkIf cfg.libreoffice.enable hunspellDicts.en_US)

        (mkIf cfg.mongodb-compass.enable mongodb-compass)

        (mkIf cfg.obs.enable obs-studio)

        (mkIf cfg.zotero.enable zotero)

        (mkIf cfg.obsidian.enable obsidian)

        (mkIf cfg.postman.enable postman)

        (mkIf cfg.sms.enable slack)
        (mkIf cfg.sms.enable webcord-vencord)
        (mkIf cfg.sms.enable zoom-us)
      ];

      sessionVariables = lib.mkIf cfg.fiji.enable {
        GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
      };
    };
  };
}
