{
  lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) types;
  inherit (config.networking) hostName;
  inherit (config.samba) mounts shares;

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
    fileSystems = let
      processMount = folder: host: let
        hostIP = resolveHostIP host;
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

        _ = checkHostConflict folder host;
      in {
        name = "/mnt/samba/${folder}";
        value = {
          device = "//${hostIP}/${folder}";
          fsType = "cifs";
          options = [
            "${automount_opts},credentials=/etc/samba/.credentials,uid=1000,gid=100"
          ];
        };
      };
    in
      mounts |> lib.mapAttrs' processMount;

    environment.etc."samba/.credentials".text = ''
      username=${secrets.samba.username}
      password=${secrets.samba.password}
    '';

    services.samba = lib.mkIf config.samba.enable {
      enable = true;
      openFirewall = true;
      settings = let
        generateShareConfig = folderPath: {
          "path" = "/mnt/samba/${folderPath}";
          "browsable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = config.users.users.c4patino.name;
          "force group" = config.users.users.c4patino.group;
        };

        mapFolderToShare = folderPath: {
          name = folderPath;
          value = generateShareConfig folderPath;
        };

        shareConfigs =
          shares
          |> map mapFolderToShare
          |> builtins.listToAttrs;
      in
        lib.mkMerge [
          {
            global = {
              "workgroup" = "WORKGROUP";
              "server string" = "smbnix";
              "netbios name" = "smbnix";
              "security" = "user";
            };
          }
          shareConfigs
        ];
    };

    services.samba-wsdd = lib.mkIf config.samba.enable {
      enable = true;
      openFirewall = true;
    };
  };
}
