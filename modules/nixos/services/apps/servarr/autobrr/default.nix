{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace resolveDatabaseHost resolveDatabaseIP readJsonOrEmpty getIn hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  isEnabled = hostHasService networkCfg.network-services hostName "autobrr";
  port = resolveServicePort networkCfg.network-services "autobrr" 7474;
  dbHost = resolveDatabaseHost pgCfg.databases "autobrr";
in {
  config = mkIf isEnabled {
    services.autobrr = {
      enable = true;
      secretFile = config.sops.secrets."autobrr".path;

      settings = {
        host = "0.0.0.0";
        port = port;

        databaseType = "postgres";
        postgresHost = resolveDatabaseIP networkCfg.devices pgCfg.databases "autobrr";
        postgresPort = 5600;
        postgresDatabase = "autobrr";
        postgresUser = "autobrr";
        postgresPass =
          "${inputs.self}/secrets/crypt/secrets.json"
          |> readJsonOrEmpty
          |> getIn "postgresql.autobrr.password";
        postgresSSLMode = "disable";
      };
    };

    systemd = {
      tmpfiles.settings."10-autobrr" = let
        configFormat = pkgs.formats.toml {};
        autobrrConfigFile = configFormat.generate "autobrr.toml" config.services.autobrr.settings;
      in {
        "/var/lib/autobrr/config.toml"."L+" = {
          argument = "${autobrrConfigFile}";
        };
      };

      services.autobrr = let
        autobrrUser = config.users.users.autobrr;

        checkAutobrrSpace = pkgs.writeShellScriptBin "check-autobrr-space" ''
          set -euo pipefail

          if [ "$#" -ne 2 ]; then
            echo "Error: Missing argument" >&2
            exit 1
          fi

          parse_space() {
            local space="''${1^^}"
            space="''${space%B}"
            ${pkgs.coreutils}/bin/numfmt --from=iec "$space"
          }

          required_space=$(parse_space "$1")
          torrent_size="$2"
          path="/mnt/nfs/servarr/torrents"

          available_space=$(${pkgs.coreutils}/bin/df --output=avail -B1 "$path" | \
            ${pkgs.gawk}/bin/awk 'END {print $1}')
          remaining_space=$((available_space - torrent_size))

          [ "$remaining_space" -gt "$required_space" ]
        '';
      in
        mkMerge [
          {
            path = [checkAutobrrSpace];
            serviceConfig = {
              DynamicUser = mkForce false;
              User = autobrrUser.name;
              Group = autobrrUser.group;
              UMask = mkForce "0002";
            };
          }
          (mkIf (dbHost == hostName) {
            after = ["postgresql.service" "pgbouncer.service"];
            requires = ["postgresql.service" "pgbouncer.service"];
            serviceConfig.RestartSec = "1s";
          })
        ];
    };

    sops.secrets = {
      "autobrr" = {
        owner = config.users.users.autobrr.name;
        group = config.users.users.autobrr.group;
      };
    };

    users = {
      users.autobrr = {
        isSystemUser = true;
        group = "autobrr";
        extraGroups = ["jellyfin" "qbittorrent"];
      };

      groups.autobrr = {};
    };

    ${namespace}.services.storage.impermanence.folders = let
      autobrrUser = config.users.users.autobrr;
    in [
      {
        directory = "/var/lib/autobrr";
        user = autobrrUser.name;
        group = autobrrUser.group;
        mode = "700";
      }
    ];
  };
}
