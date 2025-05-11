{
  lib,
  config,
  yumeami-lib,
  ...
}: let
  inherit (lib) types mkEnableOption mkIf mkOption mapAttrs' concatStringsSep;
  inherit (config.networking) hostName;

  cfg = config.nfs;

  resolveHostIP = yumeami-lib.resolveHostIP config.devices;
  checkHostConflict = yumeami-lib.checkHostConflict {
    inherit hostName;
    shares = cfg.shares;
  };
in {
  options.nfs = with types; {
    enable = mkEnableOption "NFS";
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
      type = attrsOf str;
      default = {};
      description = "Set of folder paths to mount via NFS with the target host.";
    };
  };

  config = {
    fileSystems = let
      mapFolderToMount = folder: host: let
        hostIP = resolveHostIP host;
        _ = checkHostConflict folder host;
      in {
        name = "/mnt/nfs/${folder}";
        value = {
          device = "${hostIP}:/mnt/nfs/${folder}";
          fsType = "nfs";
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
            |> map (host: "${resolveHostIP host}(${permissions})")
            |> concatStringsSep " ";
        in "/mnt/nfs/${mount.name} ${ips}";
      in
        cfg.shares
        |> map mapMountToPermissions
        |> concatStringsSep "\n";
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.enable [2049];
  };
}
