{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) enabled getAttrByNamespace;
  base = "${namespace}.bundles.homelab";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    ${namespace} = {
      services.apps.slurm = {
        enable = true;
        controlHosts = ["arisu" "chibi"];
        nodeMap = {
          arisu = {
            configString = "CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=63400 Gres=gpu:rtx3070:1,shard:rtx3070:12 Weight=1";
            partitions = ["main" "extended"];
          };
          kokoro = {
            configString = "CPUs=10 Sockets=1 CoresPerSocket=10 ThreadsPerCore=1 RealMemory=23700 Weight=100";
            partitions = ["extended"];
          };
          chibi = {
            configString = "CPUs=4 Sockets=1 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=7750 Weight=10";
            partitions = ["extended"];
          };
          shiori = {
            configString = "CPUs=4 Sockets=1 CoresPerSocket=4 ThreadsPerCore=1 RealMemory=15500 Weight=5";
            partitions = ["extended"];
          };
          tsuki = {
            configString = "CPUs=12 Sockets=1 CoresPerSocket=6 ThreadsPerCore=2 RealMemory=31500 Weight=0";
            partitions = ["main" "extended"];
          };
        };
      };

      virtualization = {
        docker = enabled;
        podman = enabled;
      };
    };
  };
}
