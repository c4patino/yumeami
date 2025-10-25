{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption filterAttrs attrNames head mkForce;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP readJsonOrEmpty getIn;
  inherit (config.networking) hostName;
  base = "${namespace}.services.apps.forgejo";
  cfg = getAttrByNamespace config base;
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  dbHost =
    pgCfg.databases
    |> filterAttrs (host: dbs: lib.elem "forgejo" dbs)
    |> attrNames
    |> head;

  port = 5300;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "forgejo";
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;

      stateDir = "/var/lib/forgejo";

      lfs.enable = true;

      database.type = mkIf (dbHost == hostName) "postgres";

      settings = {
        server = let
          url = "git.cpatino.com";
        in {
          DOMAIN = url;
          ROOT_URL = "https://${url}/";
          HTTP_PORT = port;
        };

        ui = {
          DEFAULT_THEME = "forgejo-dark";
          SHOW_USER_EMAIL = true;
        };

        database = {
          DB_TYPE = mkForce "postgres";
          HOST = mkForce "${resolveHostIP networkCfg.devices dbHost}:5600";
          NAME = "forgejo";
          USER = "forgejo";
          PASSWD =
            "${inputs.self}/secrets/crypt/secrets.json"
            |> readJsonOrEmpty
            |> getIn "postgresql.forgejo";
        };

        service.DISABLE_REGISTRATION = true;

        actions.ENABLED = true;
      };
    };

    networking.firewall.allowedTCPPorts = [2222];

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/forgejo"];
  };
}
