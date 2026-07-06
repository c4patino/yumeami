{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkPersistDir;
  base = "${namespace}.services.apps.slurm";
  cfg = getAttrByNamespace config base;
  inherit (config.networking) hostName;
in {
  config = mkIf (builtins.elem hostName cfg.controlHosts) {
    services.slurm = {
      server.enable = true;
      stateSaveLocation = "/mnt/nfs/slurm";
    };

    systemd.services.slurmctld = {
      requires = ["mnt-nfs-slurm.mount"];
      after = ["mnt-nfs-slurm.mount"];
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "slurm" "/var/spool/slurmctld")
    ];
  };
}
