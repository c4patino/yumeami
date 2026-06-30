{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkEnableOption mkIf groupBy mapAttrsToList attrNames mapAttrs concatStringsSep flatten;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP mkOpt mkOptAttrset mkListOpt;
  inherit (config.networking) hostName;
  base = "${namespace}.services.apps.slurm";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "SLURM";
      controlHosts = mkListOpt str [] "Device to use for control hosts";
      nodeMap = mkOptAttrset (submodule {
        options = {
          partitions = mkListOpt str [] "List of partitions for the node";
          configString = mkOpt str "" "Configuration string for the node capabilities";
        };
      }) {} "Mapping of node device defintitions to IPs and device configurations";
    };

  config = mkIf cfg.enable {
    services = {
      slurm = {
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

      munge.enable = true;
    };

    systemd.services.slurmctld = mkIf (builtins.elem hostName cfg.controlHosts) {
      requires = [
        "mnt-nfs-slurm.mount"
      ];

      after = [
        "mnt-nfs-slurm.mount"
      ];
    };

    sops.secrets = let
      inherit (config.users.users) munge;
    in {
      "munge-key" = {
        sopsFile = "${inputs.self}/secrets/sops/munge.key";
        format = "binary";
        path = "/etc/munge/munge.key";
        owner = munge.name;
        group = munge.group;
        mode = "0400";
      };
    };

    ${namespace}.services.storage.impermanence.folders = [
      "/var/spool/slurmctld"
      "/var/spool/slurmd"
    ];
  };
}
