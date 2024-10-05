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
						id = "DPBI57C-24TGY3G-VVNP5CZ-DDNUQ5G-7HZXQ67-WBC6ZJT-RVMAR64-SR25BAE";
						addresses = [ "tcp://100.89.24.88:22000" ];
						autoAcceptFolders = true;
					};
					"kokoro" = {
						id = "7XSPLOL-PJWH4LR-NBGYLCZ-PXJBRN2-434Q5YE-BACDCLG-T44FOWK-SZLIDQX";
						addresses = [ "tcp://100.126.34.64:22000" ];
						autoAcceptFolders = true;
					};
					"chibi" = {
						id = "R4GG6JX-FVLM2BG-26U7GTV-XVMEKIY-72YMS7D-TGYSSKJ-JWJM4NJ-OZI2ZAY";
						addresses = [ "tcp://100.101.224.25:22000" ];
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
