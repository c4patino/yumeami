{ lib, config, self, inputs, ... }:
let
	primaryHost = "arisu";
	computeNodes = [ "arisu" "kokoro" "chibi" ];
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
			controlMachine = primaryHost;
			server.enable = (config.networking.hostName == primaryHost);
			controlAddr = "100.89.24.88";

			client.enable = builtins.elem config.networking.hostName computeNodes;

			dbdserver = {
				enable = (config.networking.hostName == primaryHost);
				dbdHost = primaryHost;
			};

            nodeName = [ 
				"arisu NodeAddr=100.89.24.88 CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=63400 Gres=gpu:1,shard:12 Weight=100 State=UNKNOWN" 
				"kokoro NodeAddr=100.126.34.64 CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=23400 Weight=10 State=UNKNOWN" 
				"chibi NodeAddr=100.101.224.25 CPUs=4 Sockets=1 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=7750 Weight=50 State=UNKNOWN"
			];
            partitionName = [ 
                "main Nodes=arisu,kokoro,chibi Default=YES MaxTime=INFINITE State=UP"
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
