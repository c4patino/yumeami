{
  lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) types;
  inherit (config.networking) hostName;
  inherit (config.samba) mounts shares;
in {
  options.samba = {
    enable = lib.mkEnableOption "Samba";
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

  config = {
    fileSystems =
      lib.mapAttrs'
      (folder: host: let
        hostIP =
          if builtins.hasAttr host config.devices
          then config.devices.${host}.IP
          else builtins.throw "Host '${host}' does not exist in the devices configuration.";
      in
        if host == hostName
        then builtins.throw "Conflict: the mount host '${host}' cannot be the same as the current host '${hostName}' for folder '${folder}'."
        else if builtins.elem folder shares
        then builtins.throw "Conflict: Folder '${folder}' is in both mounts and shares. Please resolve the conflict."
        else {
          name = "/mnt/samba/${folder}";
          value = {
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

    services.samba = lib.mkIf config.samba.enable {
      enable = true;
      openFirewall = true;
      settings =
        {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "smbnix";
            "netbios name" = "smbnix";
            "security" = "user";
          };
        }
        // builtins.listToAttrs (map (folderPath: {
            name = folderPath;
            value = {
              "path" = "/mnt/samba/${folderPath}";
              "browsable" = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = config.users.users.c4patino.name;
              "force group" = config.users.users.c4patino.group;
            };
          })
          shares);
    };

    services.samba-wsdd = lib.mkIf config.samba.enable {
      enable = true;
      openFirewall = true;
    };
  };
}
