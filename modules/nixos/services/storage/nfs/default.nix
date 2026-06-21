{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption mapAttrs' concatStringsSep;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP mkOpt mkRequiredOpt mkNullableOpt mkListOpt mkOptAttrset;
  base = "${namespace}.services.storage.nfs";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "nfs";
      shares = mkListOpt (submodule {
        options = {
          name = mkOpt str [] "Folder name for the final nfs share.";
          permissions = mkListOpt str ["rw" "nohide" "insecure" "no_subtree_check"] "List of permissions to apply to the folder";
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
