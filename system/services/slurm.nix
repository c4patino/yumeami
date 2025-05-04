{
  lib,
  config,
  self,
  inputs,
  ...
}: let
  inherit (lib) mapAttrsToList types foldl';
  inherit (config.networking) hostName;

  resolveHostIP = node:
    if builtins.hasAttr node config.devices
    then config.devices.${node}.IP
    else builtins.throw "Host '${node}' does not exist in the devices configuration.";
in {
  options.slurm = {
    enable = lib.mkEnableOption "SLURM";
    controlHosts = lib.mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Device to use for control hosts";
    };
    nodeMap = lib.mkOption {
      description = "Mapping of node device defintitions to IPs and device configurations";
      type = types.attrsOf (types.submodule {
        options = {
          partitions = lib.mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of partitions for the node";
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
      client.enable = builtins.hasAttr hostName config.slurm.nodeMap;
      server.enable = builtins.elem hostName config.slurm.controlHosts;

      stateSaveLocation = "/mnt/nfs/slurm";

      nodeName = let
        generateNodeConfig = node: info: "${node} NodeAddr=${resolveHostIP node} ${info.configString} State=UNKNOWN";
      in
        config.slurm.nodeMap |> mapAttrsToList generateNodeConfig;

      partitionName = let
        generatePartitionMap = nodeMap:
          nodeMap
          |> lib.attrNames
          |> map (
            node: (nodeMap.${node}.partitions) |> map (partition: {inherit partition node;})
          )
          |> lib.flatten
          |> lib.groupBy (x: x.partition)
          |> lib.mapAttrs (name: entries: entries |> map (e: e.node));

        formatPartition = name: nodes: "${name} Nodes=${nodes |> lib.concatStringsSep ","} Default=${
          if name == "main"
          then "YES"
          else "NO"
        } MaxTime=INFINITE State=UP";

        partitionMap = config.slurm.nodeMap |> generatePartitionMap;
      in
        partitionMap |> lib.mapAttrsToList formatPartition;

      extraConfig = let
        generateHostString = host: "SlurmctldHost=${host}(${resolveHostIP host})";
        hostStrings =
          config.slurm.controlHosts
          |> map generateHostString
          |> builtins.concatStringsSep "\n";
      in ''
        ${hostStrings}
        GresTypes=gpu,shard
        TaskPlugin=task/cgroup
        SlurmdParameters=allow_ecores
        DefCpuPerGPU=1
        DefMemPerCPU=1000
        ReturnToService=2

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
