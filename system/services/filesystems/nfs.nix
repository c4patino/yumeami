{
  lib,
  config,
  ...
}: let
  inherit (lib) types;
  inherit (config.networking) hostName;
  inherit (config.nfs) mounts shares;
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
    fileSystems =
      lib.foldl'
      (acc: folder: let
        host = mounts.${folder};
        hostIP =
          if builtins.hasAttr host config.devices
          then config.devices.${host}.IP
          else throw "Host '${host}' does not exist in the devices configuration.";

        _ =
          if host == hostName
          then throw "Conflict: Mount host '${host}' cannot be the same as this host '${hostName}' for folder '${folder}'."
          else if builtins.elem folder shares
          then throw "Conflict: Folder '${folder}' is listed in both shares and mounts. Please resolve."
          else null;
      in
        acc
        // {
          "/mnt/nfs/${folder}" = {
            device = "${hostIP}:/mnt/nfs/${folder}";
            fsType = "nfs";
          };
        })
      {} (builtins.attrNames mounts);

    services.nfs.server = lib.mkIf config.nfs.enable {
      enable = true;
      exports = let
        mountLines =
          map (
            mount: let
              permissions = builtins.concatStringsSep "," mount.permissions;
              ips = builtins.concatStringsSep " " (map (ip: "${ip}(${permissions})") mount.whitelist);
            in "/mnt/nfs/${mount.name} ${ips}"
          )
          shares;
      in
        builtins.concatStringsSep "\n" mountLines;
    };

    networking.firewall.allowedTCPPorts = lib.mkIf config.nfs.enable [2049];
  };
}
