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
						id = "DRHDM4H-V3PNL37-XHUZNKB-L5OSHLY-HPZEKTW-ANIPKHM-IJHLAIO-YTLAMQJ";
						autoAcceptFolders = true;
					};
				};
				folders = {
				};
			};
        };
    };
}
