{
  pkgs,
  lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) mapAttrs;
  inherit (config.samba) mounts;
in {
  boot.supportedFilesystems = ["ntfs" "zfs"];
  services.davfs2.enable = true;

  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems = mapAttrs (folder: host: let
    inherit (config.samba) shares;
    inherit (config.networking) hostName;
    hostIP =
      if builtins.hasAttr host config.devices
      then config.devices.${host}.IP
      else builtins.throw "Host '${host}' does not exist in the devices configuration.";
  in
    if host == hostName
    then builtins.throw "Conflict: the mount host '${host} cannot be the same as the current host '${hostName}' for folder '${folder}'."
    else if builtins.elem folder shares
    then builtins.throw "Conflict: Folder '${folder}' is in both mounts and shares. Please resolve the conflict."
    else {
      "/mnt/samba/${folder}" = {
        device = "//${hostIP}/${folder}";
        fsType = "cifs";
        options = let
          automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in ["${automount_opts},credentials=/etc/samba/.credentials,uid=1000,gid=100"];
      };
    })
  mounts;

  environment.etc."samba/.credentials".text = ''
    username=${secrets.samba.username}
    password=${secrets.samba.password}
  '';

  environment.sessionVariables = {
    SAMBA = "/mnt/samba";
    SYNCTHING = "/mnt/syncthing";
  };
}
