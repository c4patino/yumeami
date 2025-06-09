{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption attrNames filterAttrs elem head;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP readJsonOrEmpty getIn;
  base = "${namespace}.services.metrics.grafana";
  cfg = getAttrByNamespace config base;
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  port = 5500;
in {
  options = mkOptionsWithNamespace base {
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
            grafanaPassword = pkgs.writeText "grafana-password.txt" (getIn "postgresql.grafana" secrets);
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
