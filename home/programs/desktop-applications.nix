{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    fiji.enable = lib.mkEnableOption "Fiji";
    libreoffice.enable = lib.mkEnableOption "LibreOffice";
    mongodb-compass.enable = lib.mkEnableOption "MongoDB Compass";
    obs.enable = lib.mkEnableOption "OBS Studio";
    obsidian.enable = lib.mkEnableOption "Obsidian";
    postman.enable = lib.mkEnableOption "Postman";
    sms.enable = lib.mkEnableOption "SMS applications";
  };

  config = {
    home = {
      packages = with pkgs; [
        (lib.mkIf config.fiji.enable fiji)
        (lib.mkIf config.fiji.enable gtk3)

        (lib.mkIf config.libreoffice.enable libreoffice-qt)
        (lib.mkIf config.libreoffice.enable hunspell)
        (lib.mkIf config.libreoffice.enable hunspellDicts.en_US)

        (lib.mkIf config.mongodb-compass.enable mongodb-compass)

        (lib.mkIf config.obs.enable obs-studio)

        (lib.mkIf config.obsidian.enable obsidian)

        (lib.mkIf config.postman.enable postman)

        (lib.mkIf config.sms.enable slack)
        (lib.mkIf config.sms.enable webcord)
        (lib.mkIf config.sms.enable zoom-us)
      ];

      sessionVariables = lib.mkIf config.fiji.enable {
        GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
      };
    };
  };
}
