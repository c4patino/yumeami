{ lib, config, ... }: {
    options = {
        github-runners.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Github Action Runner";
        };
    };

    config = lib.mkIf config.github-runners.enable {
        systemd.user.services."github-runner-${config.networking.hostName}".After = [ "sops-nix.service" ];

        services.github-runners = {
            "${config.networking.hostName}" = {
                enable = true;
				replace = true;
				ephemeral = true;
                tokenFile = /home/c4patino/.config/sops-nix/secrets/github-runner;
                url = "https://github.com/C4theBomb/nixos-config";
            };
        };
    };
}
