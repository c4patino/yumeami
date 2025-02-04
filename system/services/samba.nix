{
  lib,
  config,
  ...
}: let
  inherit (lib) types;
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

  config = lib.mkIf config.samba.enable {
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
