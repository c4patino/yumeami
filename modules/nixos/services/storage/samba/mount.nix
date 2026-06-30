{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mapAttrs';
  inherit (lib.${namespace}) getAttrByNamespace resolveHostIP readJsonOrEmpty getIn;

  cfg = getAttrByNamespace config "${namespace}.services.storage.samba";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  config = {
    fileSystems = let
      processMount = name: mountCfg: let
        hostIP = resolveHostIP networkCfg.devices mountCfg.host;
        localPath =
          if mountCfg.mountPath != null
          then mountCfg.mountPath
          else "/mnt/samba/${name}";
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in {
        name = localPath;
        value = {
          device = "//${hostIP}/${mountCfg.folder}";
          fsType = "cifs";
          options = [
            "${automount_opts},credentials=/etc/samba/.credentials,uid=1000,gid=100"
          ];
        };
      };
    in
      cfg.mounts |> mapAttrs' processMount;

    sops.secrets."samba" = {};
  };
}
