{
  lib,
  config,
  self,
  inputs,
  pkgs,
  ...
}: let
  primaryHost = "arisu";
  computeNodes = ["arisu" "kokoro" "chibi"];
in {
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
      controlAddr = "100.89.24.88";

      client.enable = builtins.elem config.networking.hostName computeNodes;
      server.enable = config.networking.hostName == primaryHost;

      nodeName = [
        "arisu NodeAddr=100.89.24.88 CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=63443 Gres=gpu:rtx3070:1,shard:12 Weight=1 State=UNKNOWN"
        "kokoro NodeAddr=100.126.34.64 CPUs=10 Sockets=1 CoresPerSocket=10 ThreadsPerCore=1 RealMemory=23746 Weight=100 State=UNKNOWN"
        "chibi NodeAddr=100.101.224.25 CPUs=4 Sockets=1 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=7750 Weight=10 State=UNKNOWN"
      ];

      partitionName = [
        "main Nodes=arisu,chibi Default=YES MaxTime=INFINITE State=UP"
        "extended Nodes=arisu,kokoro,chibi Default=NO MaxTime=INFINITE State=UP"
      ];

      extraConfig = ''
        GresTypes=gpu,shard
        TaskPlugin=task/cgroup
        SlurmdParameters=allow_ecores
        DefCpuPerGPU=1
        DefMemPerCPU=1000
        ReturnToService=2

        AccountingStorageType=accounting_storage/slurmdbd
        AccountingStorageTRES=gres/gpu

        JobAcctGatherType=jobacct_gather/linux

        TaskProlog=${inputs.dotfiles + "/slurm/prolog.sh"}
        TaskEpilog=${inputs.dotfiles + "/slurm/epilog.sh"}
      '';

      extraCgroupConfig = ''
        ConstrainCores=yes
        ConstrainDevices=yes
        ConstrainRAMSpace=yes
      '' + (
          if config.networking.hostName != "chibi"
          then ''
            ConstrainSwapSpace=yes
            AllowedSwapSpace=0
          ''
          else ''''
        );

      extraConfigPaths = [(inputs.dotfiles + "/slurm/config")];

      dbdserver = {
        enable = config.networking.hostName == primaryHost;
        dbdHost = primaryHost;
        storagePassFile = "${self}/secrets/crypt/mysql.txt";
      };
    };

    services.munge.enable = true;
    environment.etc."munge/munge.key" = {
      source = "${self}/secrets/crypt/munge.key";
      user = "munge";
      group = "munge";
      mode = "0400";
    };

    services.mysql = {
      enable = config.networking.hostName == primaryHost;
      initialDatabases = [{name = "slurm_acct";}];
      ensureDatabases = ["slurm_acct"];
      package = pkgs.mariadb;
    };
  };
}
