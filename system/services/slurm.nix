{
  lib,
  config,
  self,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib) mapAttrsToList types foldl';
  inherit (config.networking) hostName;
in {
  options.slurm = {
    enable = lib.mkEnableOption "SLURM";
    primaryHost = lib.mkOption {
      type = types.str;
      default = "";
      description = "Device to use for the primary SLURM control host";
    };
    nodeMap = lib.mkOption {
      description = "Mapping of node device defintitions to IPs and device configurations.";
      type = types.attrsOf (types.submodule {
        options = {
          partitions = lib.mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of partitions for the node.";
          };
          configString = lib.mkOption {
            type = types.str;
            default = "";
            description = "Configuration string for the node capabilities";
          };
        };
      });
      default = {};
    };
  };

  config = lib.mkIf config.slurm.enable {
    services.slurm = {
      controlMachine = config.slurm.primaryHost;
      controlAddr = config.devices.${config.slurm.primaryHost}.IP;

      client.enable = builtins.hasAttr hostName config.slurm.nodeMap;
      server.enable =
        if builtins.hasAttr config.slurm.primaryHost config.devices
        then config.slurm.primaryHost == hostName
        else builtins.throw "Host '${config.slurm.primaryHost} does not exist in the devices configuration.";

      nodeName =
        mapAttrsToList (
          node: value: let
            nodeIP =
              if builtins.hasAttr node config.devices
              then config.devices.${node}.IP
              else builtins.throw "Host '${node}' does not exist in the devices configuration.";
          in "${node} NodeAddr=${nodeIP} ${value.configString} State=UNKNOWN"
        )
        config.slurm.nodeMap;

      partitionName = let
        partitionMap = foldl' (
          acc: node: let
            partitions = config.slurm.nodeMap.${node}.partitions;
          in
            foldl' (innerAcc: partition:
              acc
              // {
                ${partition} = (acc.${partition} or []) ++ [node];
              })
            acc
            partitions
        ) {} (builtins.attrNames config.slurm.nodeMap);

        formatPartition = name: nodes: "${name} Nodes=${lib.concatStringsSep "," nodes} Default=${
          if name == "main"
          then "YES"
          else "NO"
        } MaxTime=INFINITE State=UP";
      in
        map (name: formatPartition name partitionMap.${name}) (builtins.attrNames partitionMap);

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

      extraCgroupConfig =
        ''
          ConstrainCores=yes
          ConstrainDevices=yes
          ConstrainRAMSpace=yes
        ''
        + (
          if config.networking.hostName != "chibi"
          then ''
            ConstrainSwapSpace=yes
            AllowedSwapSpace=0
          ''
          else ''''
        );

      extraConfigPaths = [(inputs.dotfiles + "/slurm/config")];

      dbdserver = {
        enable = config.slurm.primaryHost == hostName;
        dbdHost = config.slurm.primaryHost;
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
      enable = config.slurm.primaryHost == hostName;
      ensureDatabases = ["slurm_acct_db"];
      ensureUsers = [
        {
          name = "slurm";
          ensurePermissions = {
            "slurm_acct_db.*" = "ALL PRIVILEGES";
          };
        }
      ];
      package = pkgs.mariadb;
    };
  };
}
