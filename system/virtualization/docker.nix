{ lib, config, ... }: {
    options = {
        docker.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Docker support";
        };
    };

    config = lib.mkIf config.docker.enable {
        virtualisation.docker = {
            enable = true;
            rootless = {
                enable = true;
                setSocketVariable = true;
            };
        };
    };
}

