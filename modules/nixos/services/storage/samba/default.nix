{
  config,
  inputs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  inherit (config.users) users;
  base = "${namespace}.services.storage.samba";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  options = with types;
    mkOptionsWithNamespace base {
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
        hostIP = resolveHostIP networkCfg.devices host;
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
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

    environment.etc."samba/.credentials".text = let
      secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/secrets.json";
    in ''
      username=${getIn "samba.username" secrets}
      password=${getIn "samba.password" secrets}
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
          "force user" = users.c4patino.name;
          "force group" = users.c4patino.group;
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
