{
  lib,
  config,
  self,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf mapAttrsToList types groupBy flatten mapAttrs concatStringsSep attrNames;
  inherit (config.networking) hostName;
  cfg = config.slurm;

  resolveHostIP = node:
    if builtins.hasAttr node config.devices
    then config.devices.${node}.IP
    else builtins.throw "Host '${node}' does not exist in the devices configuration.";
in {
  options.slurm = with types; {
    enable = mkEnableOption "SLURM";
    controlHosts = mkOption {
      type = listOf str;
      default = [];
      description = "Device to use for control hosts";
    };
    nodeMap = mkOption {
      description = "Mapping of node device defintitions to IPs and device configurations";
      type = attrsOf (submodule {
        options = {
          partitions = mkOption {
            type = listOf str;
            default = [];
            description = "List of partitions for the node";
          };
          configString = mkOption {
            type = str;
            default = "";
            description = "Configuration string for the node capabilities";
          };
        };
      });
      default = {};
    };
  };

  config = mkIf cfg.enable {
    services.slurm = {
      client.enable = builtins.hasAttr hostName cfg.nodeMap;
      server.enable = builtins.elem hostName cfg.controlHosts;

      stateSaveLocation = "/mnt/nfs/slurm";

      nodeName = let
        generateNodeConfig = node: info: "${node} NodeAddr=${resolveHostIP node} ${info.configString} State=UNKNOWN";
      in
        cfg.nodeMap |> mapAttrsToList generateNodeConfig;

      partitionName = let
        generatePartitionMap = nodeMap:
          nodeMap
          |> attrNames
          |> map (
            node: (cfg.nodeMap.${node}.partitions) |> map (partition: {inherit partition node;})
          )
          |> flatten
          |> groupBy (x: x.partition)
          |> mapAttrs (name: entries: entries |> map (e: e.node));

        formatPartition = name: nodes: "${name} Nodes=${nodes |> concatStringsSep ","} Default=${
          if name == "main"
          then "YES"
          else "NO"
        } MaxTime=INFINITE State=UP";
      in
        cfg.nodeMap
        |> generatePartitionMap
        |> mapAttrsToList formatPartition;

      extraConfig = let
        generateHostString = host: "SlurmctldHost=${host}(${resolveHostIP host})";
        hostStrings =
          cfg.controlHosts
          |> map generateHostString
          |> concatStringsSep "\n";
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
