{ lib, config, self, inputs, ... }:
let
	enabledHosts = [ "arisu" "chibi" ];
in
{
    options = {
        slurm.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable SLURM";
        };
    };

    config = lib.mkIf config.slurm.enable {
        services.slurm = {
			controlMachine = "arisu";
			client.enable = true;
			server.enable = builtins.elem config.networking.hostName enabledHosts;

			dbdserver = {
				enable = (config.networking.hostName == "arisu");
				dbdHost = "arisu";
			};

            nodeName = [ 
				"arisu CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=63400 Gres=gpu:1,shard:12 State=UNKNOWN" 
				# "kokoro CPUs=12 Sockets=1 CoresPerSocket=10 ThreadsPerCore=2 RealMemory=24300 Gres=gpu:1,shard:12 State=UNKNOWN" 
				"chibi CPUs=4 Sockets=1 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=7750 State=UNKNOWN"
			];
            partitionName = [ 
                "main Nodes=arisu,chibi Default=YES MaxTime=INFINITE State=UP"
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
