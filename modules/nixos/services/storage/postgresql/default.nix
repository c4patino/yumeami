{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.postgresql";
  cfg = getAttrByNamespace config base;

  port = 5600;
in {
  options = with types;
    mkOptionsWithNamespace base {
      databases = mkOption {
        type = attrsOf (listOf str);
        default = {};
        description = "Map of hosts to list of databases.";
      };
    };

  config = mkIf (hasAttr hostName cfg.databases) {
    services = {
      postgresql = {
        enable = true;
        enableTCPIP = true;

        settings = {
          port = port;
        };

        authentication = let
          permissionEntries =
            cfg.databases
            |> getAttr hostName
            |> map (service: "host            ${service}        ${service}    0.0.0.0/0     md5")
            |> concatStringsSep "\n";
        in ''
          # TYPE          DATABASE          USER          ADDRESS       METHOD
          local           all               all                         trust
          ${permissionEntries}
        '';

        ensureDatabases = getAttr hostName cfg.databases;

        ensureUsers =
          cfg.databases
          |> getAttr hostName
          |> map (service: {
            name = service;
            ensureDBOwnership = true;
          });
      };

      postgresqlBackup = {
        enable = true;
        databases = [
          "forgejo"
          "grafana"
          "vaultwarden"
        ];
        compression = "zstd";
        compressionLevel = 4;
        startAt = "*-*-* 23:00:00";
      };
    };

    networking.firewall.allowedTCPPorts = [port];

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/postgresql"];
  };
}
