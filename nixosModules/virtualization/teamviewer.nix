{ pkgs, lib, config, ... }: {
    options = {
        teamviewer.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable TeamViewer";
        };
    };

    config = lib.mkIf config.teamviewer.enable {
        environment.systemPackages = with pkgs; [
            teamviewer
        ];

        services.teamviewer.enable = true;
    };
}
