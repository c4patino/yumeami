{
  lib,
  yumeami-lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption mkMerge mkIf mapAttrs';
  inherit (config.networking) hostName;
  cfg = config.samba;

  resolveHostIP = yumeami-lib.resolveHostIP config.devices;
  checkHostConflict = yumeami-lib.checkHostConflict {
    inherit hostName;
    shares = cfg.shares;
  };
in {
  options.samba = with types; {
    enable = mkEnableOption "Samba";
    shares = mkOption {
      type = listOf str;
      default = [];
      description = "List of folder paths to share via Samba.";
    };
    mounts = mkOption {
      type = attrsOf str;
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
      cfg.mounts |> mapAttrs' processMount;

    environment.etc."samba/.credentials".text = ''
      username=${secrets.samba.username}
      password=${secrets.samba.password}
    '';

    services.samba = mkIf cfg.enable {
      enable = true;
      openFirewall = true;
      settings = let
        mkShare = folderPath: {
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
          value = mkShare folderPath;
        };

        shareConfigs =
          cfg.shares
          |> map mapFolderToShare
          |> builtins.listToAttrs;
      in
        mkMerge [
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

    services.samba-wsdd = mkIf cfg.enable {
      enable = true;
      openFirewall = true;
    };
  };
}
