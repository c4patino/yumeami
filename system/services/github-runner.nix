{ pkgs, lib, config, ... }: {
    options = {
        github-runners.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Github Action Runner";
        };
    };

    config = lib.mkIf config.github-runners.enable {
        systemd.user.services."github-runner-${config.networking.hostName}".after = [ "sops-nix.service" ];

        services.github-runners = {
            "${config.networking.hostName}" = {
                enable = true;
				replace = true;
				ephemeral = true;
                tokenFile = config.sops.secrets."github/runner".path;
                url = "https://github.com/C4theBomb/nixos-config";
            };
            "${config.networking.hostName}-oasys" = {
                enable = true;
				replace = true;
				ephemeral = true;
                tokenFile = config.sops.secrets."github/runner-oasys".path;
                url = "https://github.com/oasys-mas";
				user = "c4patino";
				group = "users";
				extraPackages = with pkgs; [ openssl cudaPackages.cudatoolkit ];
            };
        };
	};
}
