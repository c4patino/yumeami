{
  lib,
  config,
  ...
}: let
  inherit (lib) types;
  inherit (config.networking) hostName;
  inherit (config.nfs) mounts shares;

  hostIP =
    if builtins.hasAttr hostName config.devices
    then config.devices.${hostName}.IP
    else throw "Host '${hostName}' does not exist in the devices configuration.";
in {
  options.nfs = {
    enable = lib.mkEnableOption "NFS";
    shares = lib.mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of folder paths to share via Samba.";
    };
    mounts = lib.mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "List of the folder paths to mount via Samba and the host.";
    };
  };

  config = let
    fileSystemsConfig =
      lib.foldl'
      (acc: folder: let
        host = mounts.${folder};
        hostIP =
          if builtins.hasAttr host config.devices
          then config.devices.${host}.IP
          else throw "Host '${host}' does not exist in the devices configuration.";
      in
        if host == hostName
        then throw "Conflict: Mount host '${host}' cannot be the same as this host '${hostName}' for folder '${folder}'."
        else if builtins.elem folder shares
        then throw "Conflict: Folder '${folder}' is listed in both shares and mounts. Please resolve."
        else
          acc
          // {
            "/mnt/nfs/${folder}" = {
              device = "//${hostIP}/${folder}";
              fsType = "nfs";
            };
          })
      {}
      (builtins.attrNames mounts);
  in
    {
      fileSystems = fileSystemsConfig;
    }
    // lib.mkIf config.nfs.enable
    {
      services.nfs.server = {
        enable = true;
        exports = builtins.concatStringsSep "\n" (map (name: "/mnt/nfs/${name} ${hostIP}(rw,nohide,insecure,no_subtree_check)")) shares;
      };

      networking.firewall.allowedTCPPorts = [2049];
    };
}
