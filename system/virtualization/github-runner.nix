{ pkgs, lib, config, self, secrets, ... }: {
    options = {
        github-runners.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Github Action Runner";
        };
    };

    config = lib.mkIf config.github-runners.enable {
        services.github-runners = {
            arisu = {
                enable = true;
                ephemeral = true;
                tokenFile = /home/c4patino/.config/sops-nix/secrets/github-runner;
                url = "https://github.com/C4theBomb/nixos-config";
            };
        };
    };
}
