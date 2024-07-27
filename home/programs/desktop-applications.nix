{ pkgs, lib, config, ... }: {
    options = {
        sms.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable SMS applications";
        };
        libreoffice.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable LibreOffice";
        };
        obs.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable OBS Studio";
        };
        postman.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Postman";
        };
        mongodb-compass.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable MongoDB Compass";
        };
        obsidian.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Obsidian";
        };
    };

    config = {
        home.packages = with pkgs; [
            (lib.mkIf config.sms.enable webcord)
            (lib.mkIf config.sms.enable slack)
            (lib.mkIf config.sms.enable zoom-us)

            (lib.mkIf config.obs.enable obs-studio)

            (lib.mkIf config.postman.enable postman)

            (lib.mkIf config.mongodb-compass.enable mongodb-compass)

            (lib.mkIf config.obsidian.enable obsidian)

            (lib.mkIf config.libreoffice.enable libreoffice-qt)
            (lib.mkIf config.libreoffice.enable hunspell)
            (lib.mkIf config.libreoffice.enable hunspellDicts.en_US)
        ];
    };
}
