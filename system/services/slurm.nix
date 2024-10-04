{ lib, config, self, inputs, ... }: {
    options = {
        slurm.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable SLURM";
        };
    };

    config = lib.mkIf config.slurm.enable {
        services.slurm = {
			dbdserver = {
				dbdHost = "arisu";

				enable = (config.networking.hostName == "arisu");
				

			};

            server.enable = (config.networking.hostName == "arisu");

            client.enable = true;

            controlMachine = "arisu";
            nodeName = [ 
				"arisu CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=63400 Gres=gpu:1,shard:12 State=UNKNOWN" 
			];
            partitionName = [ 
                "main Nodes=arisu Default=YES MaxTime=INFINITE State=UP"
            ];

			extraConfig = ''
				TaskPlugin=task/cgroup
				GresTypes=gpu,shard
				DefCpuPerGPU=1
				DefMemPerCPU=1000
				ReturnToService=2
			'';

			extraConfigPaths = [
				(inputs.dotfiles + "/slurm")
			];
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
