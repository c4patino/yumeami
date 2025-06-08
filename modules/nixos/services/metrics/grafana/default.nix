{
  config,
  inputs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.metrics.grafana";
  cfg = getAttrByNamespace config base;
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  port = 5500;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Grafana";
    };

  config = mkIf cfg.enable {
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
            grafanaPassword = pkgs.writeText "grafana-password.txt" (getIn secrets "postgresql.grafana");
          in "$__file{${grafanaPassword}}";
        };

        panels.enable_alpha = true;
      };

      provision = {
        datasources.settings.datasources = [
        ];
      };
    };
  };
}
