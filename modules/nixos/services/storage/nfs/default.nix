{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkOption mkEnableOption mkIf mapAttrs' concatStringsSep;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP;
  base = "${namespace}.services.storage.nfs";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "nfs";
      shares = mkOption {
        type = listOf (submodule {
          options.name = mkOption {
            type = str;
            default = [];
            description = "Folder name for the final nfs share.";
          };
          options.permissions = mkOption {
            type = listOf str;
            default = ["rw" "nohide" "insecure" "no_subtree_check"];
            description = "List of permissions to apply to the folder";
          };
          options.whitelist = mkOption {
            type = listOf str;
            default = [];
            description = "List of devices to whitelist on the nfs share.";
          };
        });
        default = [];
        description = "List of the folder paths to share via NFS.";
      };
      mounts = mkOption {
        type = attrsOf (submodule {
          options.host = mkOption {
            type = str;
            description = "Target host to mount from.";
          };
          options.folder = mkOption {
            type = str;
            description = "Remote folder path on the NFS server.";
          };
          options.mountPath = mkOption {
            type = nullOr str;
            default = null;
            description = "Local mount path. If null, defaults to /mnt/nfs/{name}.";
          };
        });
        default = {};
        description = "Set of NFS mounts with custom configuration.";
      };
    };

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
            "x-systemd.automount"
          ];
        };
      };
    in
      cfg.mounts |> mapAttrs' mapFolderToMount;

    services.nfs.server = mkIf cfg.enable {
      enable = true;
      exports = let
        mapMountToPermissions = mount: let
          permissions = mount.permissions |> concatStringsSep ",";
          ips =
            mount.whitelist
            |> map (host: "${resolveHostIP networkCfg.devices host}(${permissions})")
            |> concatStringsSep " ";
        in "/mnt/nfs/${mount.name} ${ips}";
      in
        cfg.shares
        |> map mapMountToPermissions
        |> concatStringsSep "\n";
    };

    ${namespace}.services.storage.impermanence.folders = mkIf (cfg.enable && cfg.shares != []) (
      ["/var/lib/nfs"] ++ (cfg.shares |> map (s: "/mnt/nfs/${s.name}"))
    );

    networking.firewall.allowedTCPPorts = mkIf cfg.enable [2049];
  };
}
