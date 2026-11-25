{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  base = "${namespace}.bundles.homelab";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    ${namespace} = {
      services.apps.slurm = {
        enable = true;
        controlHosts = ["chibi"];
        nodeMap = {
          arisu = {
            configString = "CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=63400 Gres=gpu:rtx3070:1,shard:rtx3070:12 Weight=1";
            partitions = ["main"];
          };
          kokoro = {
            configString = "CPUs=8 Sockets=1 CoresPerSocket=8 ThreadsPerCore=1 RealMemory=31500";
            state = "DOWN";
          };
          tsuki = {
            configString = "CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=31500 Weight=1";
            partitions = ["main"];
          };
        };
      };
    };
  };
}
