{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption mkIf groupBy mapAttrsToList attrNames mapAttrs concatStringsSep flatten;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP;
  inherit (config.networking) hostName;
  base = "${namespace}.services.ci.slurm";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  options = with types;
    mkOptionsWithNamespace base {
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
        mkNodeConfig = node: info: "${node} NodeAddr=${resolveHostIP networkCfg.devices node} ${info.configString} State=UNKNOWN";
      in
        mapAttrsToList mkNodeConfig cfg.nodeMap;

      partitionName = let
        mkPartitions = nodeMap:
          nodeMap
          |> attrNames
          |> map (
            node:
              (cfg.nodeMap.${node}.partitions)
              |> map (partition: {inherit partition node;})
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
        |> mkPartitions
        |> mapAttrsToList formatPartition;

      extraConfig = let
        mkHostString = host: "SlurmctldHost=${host}(${resolveHostIP networkCfg.devices host})";
        hostStrings =
          cfg.controlHosts
          |> map mkHostString
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
          if hostName != "chibi"
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
      source = "${inputs.self}/secrets/crypt/munge.key";
      user = "munge";
      group = "munge";
      mode = "0400";
    };

    ${namespace}.services.storage.impermanence.folders = ["/var/spool/slurmctld" "/var/spool/slurmd"];
  };
}
