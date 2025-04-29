{
  lib,
  config,
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
            "/mnt/samba/${folder}" = {
              device = "//${hostIP}/${folder}";
              fsType = "cifs";
              options = let
                automountOpts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
              in ["${automountOpts},credentials=/etc/samba/.credentials,uid=1000,gid=100"];
            };
          })
      {}
      (builtins.attrNames mounts);
  in
    {
      fileSystems = fileSystemsConfig;

      environment.etc."samba/.credentials".text = ''
        username=${config.secrets.samba.username}
        password=${config.secrets.samba.password}
      '';
    }
    // lib.mkIf config.samba.enable {
      services.samba = {
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
            config.samba.shares);
      };

      services.samba-wsdd = {
        enable = true;
        openFirewall = true;
      };
    };
}
