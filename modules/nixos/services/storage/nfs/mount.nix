{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mapAttrs';
  inherit (lib.${namespace}) getAttrByNamespace resolveHostIP;
  cfg = getAttrByNamespace config "${namespace}.services.storage.nfs";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  config = {
    fileSystems = let
      mapFolderToMount = name: mntCfg: let
        hostIP = resolveHostIP networkCfg.devices mntCfg.host;
        localPath =
          if mntCfg.mountPath != null
          then mntCfg.mountPath
          else "/mnt/nfs/${name}";
      in {
        name = localPath;
        value = {
          device = "${hostIP}:${mntCfg.folder}";
          fsType = "nfs";
          options = [
            "_netdev"
            "nofail"
            "rsize=1048576"
            "wsize=1048576"
            "actimeo=60"
            "noatime"
            "x-systemd.automount"
            "x-systemd.after=network-online.target tailscaled.service"
            "x-systemd.wants=tailscaled.service"
          ];
        };
      };
    in
      cfg.mounts |> mapAttrs' mapFolderToMount;
  };
}
