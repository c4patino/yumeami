{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkMerge concatStringsSep;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP mkOpt mkRequiredOpt mkNullableOpt mkListOpt mkOptAttrset mkPersistRootDir;
  base = "${namespace}.services.storage.nfs";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  imports = [
    ./mount.nix
  ];

  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "nfs";
      shares = mkListOpt (submodule {
        options = {
          name = mkOpt str [] "Folder name for the final nfs share.";
          permissions = mkListOpt str ["rw" "nohide" "insecure" "no_subtree_check" "no_root_squash" "sync"] "List of permissions to apply to the folder";
          whitelist = mkListOpt str [] "List of devices to whitelist on the nfs share.";
        };
      }) [] "List of the folder paths to share via NFS.";
      mounts = mkOptAttrset (submodule {
        options = {
          host = mkRequiredOpt str "Target host to mount from.";
          folder = mkRequiredOpt str "Remote folder path on the NFS server.";
          mountPath = mkNullableOpt str null "Local mount path. If null, defaults to /mnt/nfs/{name}.";
        };
      }) {} "Set of NFS mounts with custom configuration.";
    };

  config = mkIf cfg.enable {
    services.nfs.server = {
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

    systemd.services = {
      nfs-idmapd.unitConfig.RequiresMountsFor = [
        "/var/lib/nfs"
        "/var/lib/nfs/rpc_pipefs"
      ];
      nfsdcld.unitConfig.RequiresMountsFor = [
        "/var/lib/nfs"
        "/var/lib/nfs/rpc_pipefs"
      ];
      nfs-server.unitConfig.RequiresMountsFor = [
        "/var/lib/nfs"
      ];
    };

    ${namespace}.services.storage.impermanence.folders = mkMerge [
      [(mkPersistRootDir config "/var/lib/nfs" "700")]
      (
        mkIf (cfg.shares != []) (
          cfg.shares
          |> map (s: mkPersistRootDir config "/mnt/nfs/${s.name}" "777")
        )
      )
    ];

    networking.firewall.allowedTCPPorts = [2049];
  };
}
