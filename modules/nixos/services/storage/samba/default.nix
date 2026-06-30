{
  config,
  lib,
  namespace,
  ...
} @ args: let
  inherit (lib) types mkIf mkEnableOption mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkRequiredOpt mkNullableOpt mkListOpt mkOptAttrset;
  inherit (config.users) users;

  base = "${namespace}.services.storage.samba";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    (import ./mount.nix args)
  ];

  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Samba";
      shares = mkListOpt str [] "List of folder paths to share via Samba.";
      mounts = mkOptAttrset (submodule {
        options = {
          host = mkRequiredOpt str "Target host to mount from.";
          folder = mkRequiredOpt str "Remote folder/share name on the Samba server.";
          mountPath = mkNullableOpt str null "Local mount path. If null, defaults to /mnt/samba/{name}.";
        };
      }) {} "Set of Samba mounts with custom configuration.";
    };

  config = mkIf cfg.enable {
    services = {
      samba = {
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

      samba-wsdd = {
        enable = true;
        openFirewall = true;
      };
    };

    ${namespace}.services.storage.impermanence.folders = mkMerge [
      ["/var/lib/samba"]
      (mkIf (cfg.shares != []) (cfg.shares |> map (s: "/mnt/samba/${s}")))
    ];
  };
}
