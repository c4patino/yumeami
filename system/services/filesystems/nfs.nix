{
  lib,
  config,
  ...
}: let
  inherit (lib) types;
  inherit (config.nfs) mounts shares;
  inherit (config.networking) hostName;

  resolveHostIP = host:
    if builtins.hasAttr host config.devices
    then config.devices.${host}.IP
    else throw "Host '${host}' does not exist in the devices configuration.";

  checkHostConflict = folder: host:
    if host == hostName
    then throw "Conflict: Mount host '${host}' cannot be the same as this host '${hostName}' for folder '${folder}'."
    else if builtins.elem folder shares
    then throw "Conflict: Folder '${folder}' is listed in both shares and mounts. Please resolve."
    else null;
in {
  options.nfs = {
    enable = lib.mkEnableOption "NFS";
    shares = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = lib.mkOption {
            type = types.str;
            default = [];
            description = "Folder name for the final nfs share.";
          };
          permissions = lib.mkOption {
            type = types.listOf types.str;
            default = ["rw" "nohide" "insecure" "no_subtree_check"];
            description = "List of permissions to apply to the folder";
          };
          whitelist = lib.mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of devices to whitelist on the nfs share.";
          };
        };
      });
      default = [];
      description = "List of the folder paths to share via NFS.";
    };
    mounts = lib.mkOption {
      type = types.attrsOf types.str;
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
      mounts |> lib.mapAttrs' mapFolderToMount;

    services.nfs.server = lib.mkIf config.nfs.enable {
      enable = true;
      exports = let
        mapMountToPermissions = mount: let
          permissions = mount.permissions |> builtins.concatStringsSep ",";
          ips =
            mount.whitelist
            |> map (host: "${resolveHostIP host}(${permissions})")
            |> builtins.concatStringsSep " ";
        in "/mnt/nfs/${mount.name} ${ips}";
      in
        shares
        |> map mapMountToPermissions
        |> builtins.concatStringsSep "\n";
    };

    networking.firewall.allowedTCPPorts = lib.mkIf config.nfs.enable [2049];
  };
}
