{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    fiji.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Fiji";
    };
    libreoffice.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable LibreOffice";
    };
    mongodb-compass.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable MongoDB Compass";
    };
    obs.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable OBS Studio";
    };
    obsidian.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Obsidian";
    };
    postman.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Postman";
    };
    sms.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable SMS applications";
    };
  };

  config = {
    home.packages = with pkgs; [
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

    home.sessionVariables = lib.mkIf config.fiji.enable {
      GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
    };
  };
}
