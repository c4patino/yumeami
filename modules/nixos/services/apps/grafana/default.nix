{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf attrNames filterAttrs elem head;
  inherit (lib.${namespace}) getAttrByNamespace resolveHostIP readJsonOrEmpty getIn hostHasService flattenHostServices getServicePort;
  inherit (config.networking) hostName;

  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  isEnabled = hostHasService networkCfg.network-services hostName "grafana";
  port = getServicePort networkServices "grafana" 5500;
in {
  config = mkIf isEnabled {
    services.grafana = {
      enable = true;
      settings = {
        server = {
          root_url = "https://grafana.yumeami.sh";
          domain = "grafana.yumeami.sh";
          enforce_domain = true;
          http_addr = "0.0.0.0";
          http_port = port;
        };

        users.allow_signup = false;
        "auth.anonymous".enabled = true;

        database = {
          type = "postgres";
          host = let
            ip =
              pgCfg.databases
              |> filterAttrs (host: dbs: elem "grafana" dbs)
              |> attrNames
              |> head
              |> resolveHostIP networkCfg.devices;
          in "${ip}:5600";
          name = "grafana";
          user = "grafana";
          password = let
            secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/secrets.json";
            grafanaPassword = pkgs.writeText "grafana-password.txt" (getIn "postgresql.grafana" secrets);
          in "$__file{${grafanaPassword}}";
        };

        panels.enable_alpha = true;

        security.secret_key = "SW2YcwTIb9zpOOhoPsMm";
      };

      provision = {
        datasources.settings.datasources = [
        ];
      };
    };

    systemd.services.grafana = let
      dbHost =
        pgCfg.databases
        |> filterAttrs (host: dbs: elem "grafana" dbs)
        |> attrNames
        |> head;
    in
      mkIf (dbHost == config.networking.hostName) {
        after = ["postgresql.service" "pgbouncer.service"];
        requires = ["postgresql.service" "pgbouncer.service"];
        serviceConfig = {
          RestartSec = lib.mkForce "1s";
        };
      };
  };
}
