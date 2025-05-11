{
  pkgs,
  lib,
  yumeami-lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) mkEnableOption mkIf filterAttrs head attrNames;
  cfg = config.grafana;
  pgCfg = config.postgresql;

  resolveHostIP = yumeami-lib.resolveHostIP config.devices;

  port = 5500;
in {
  options.grafana.enable = mkEnableOption "Grafana";

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
              |> filterAttrs (host: dbs: lib.elem "grafana" dbs)
              |> attrNames
              |> head
              |> resolveHostIP;
          in "${ip}:5600";
          name = "grafana";
          user = "grafana";
          password = let
            grafanaPassword = pkgs.writeText "grafana-password.txt" secrets.postgresql.grafana;
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
