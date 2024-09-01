{ pkgs, lib, config, self, ... }: {
    options = {
        slurm.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable SLURM";
        };
    };

    config = lib.mkIf config.slurm.enable {
        services.slurm = {
            server.enable = (config.networking.hostName == "arisu");
            client.enable = true;

            controlMachine = "arisu";
            nodeName = [ "arisu" ];
            partitionName = [ 
                "main Nodes=arisu Default=YES MaxTime=INFINITE State=UP"
            ];
        };

        networking.firewall = {
            enable = false;
        };

        services.munge.enable = true;
        environment.etc."munge/munge.key" = {
            source = "${self}/secrets/crypt/munge.key";
            user = "munge";
            group = "munge";
            mode = "0400";
        };
    };
}
