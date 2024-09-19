{ pkgs, lib, config, self, secrets, ... }: {
    options = {
        github-runners.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Github Action Runner";
        };
    };

    config = lib.mkIf config.github-runners.enable {
        systemd.user.services.github-runner-arisu.after = [ "sops-nix.service" ];
        # systemd.user.services.github-runner-arisu-oasys.after = [ "sops-nix.service" ];

        services.github-runners = {
            arisu = {
                enable = true;
                ephemeral = true;
                tokenFile = /home/c4patino/.config/sops-nix/secrets/github-runner;
                url = "https://github.com/C4theBomb/nixos-config";
            };
            # arisu-oasys = {
            #     enable = true;
            #     ephemeral = true;
            #     tokenFile = /home/c4patino/.config/sops-nix/secrets/github-runner;
            #     url = "https://github.com/oasys-mas";
            # };
        };
    };
}
