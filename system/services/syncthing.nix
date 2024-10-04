{ lib, config, ... }: {
    options = {
        syncthing.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable syncthing";
        };
    };

    config = lib.mkIf config.syncthing.enable {
        services.syncthing = {
			enable = true;
			settings = {
				devices = {
					"arisu" = { 
						autoAcceptFolders = true; 
					};
				};
				folders = {

				};

			};
        };
    };
}
