{ lib, config, ... }: {
    options = {
        docker.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Docker support";
        };
    };

    config = lib.mkIf config.docker.enable {
		hardware.nvidia-container-toolkit.enable = config.nvidia.enable;

        virtualisation = {
			containers = {
				enable = true;
			};

			docker = {
				enable = true;

				daemon.settings.features.cdi = true;

				rootless = {
					enable = true;
					setSocketVariable = true;
					daemon.settings.features.cdi = true;
				};
			};

			oci-containers.backend = "docker";
		};
    };
}

