{ lib, config, ... }: 
let
	hostName = config.networking.hostName;
	sharedMachines = [ "arisu" "kokoro" "chibi" ];
in
{
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
			dataDir = "/mnt/syncthing/";
			user = "c4patino";
			group = "syncthing";

			settings = {
				devices = {
					"arisu" = {
						id = "DRHDM4H-V3PNL37-XHUZNKB-L5OSHLY-HPZEKTW-ANIPKHM-IJHLAIO-YTLAMQJ";
						autoAcceptFolders = true;
					};
					"kokoro" = {
						id = "GNLFB3X-TFDTLJY-NSZWWUT-JOWSBFQ-DXLZA4E-OTXL2SD-GNUQBY3-3R6AMAB";
						autoAcceptFolders = true;
					};
					"chibi" = {
						id = "QV2Y5R5-3RHJDCW-L5L633X-UMASLYU-SASAOPE-CSCYPVH-XPZSWQX-UZEEJA7";
						autoAcceptFolders = true;
					};
				};
				folders = {
					"shared" = {
						path = "/mnt/syncthing/shared";
						enable = (builtins.elem hostName sharedMachines);
						devices = sharedMachines;
					};
				};
			};
        };

		systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
    };
}
