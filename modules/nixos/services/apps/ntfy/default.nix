{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkForce;
  inherit (lib.${namespace}) getAttrByNamespace readJsonOrEmpty getIn resolveDatabaseIP hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  pgCfg = getAttrByNamespace config "${namespace}.services.storage.postgresql";

  isEnabled = hostHasService networkCfg.network-services hostName "ntfy";
  port = resolveServicePort networkCfg.network-services "ntfy" 5201;
in {
  config = mkIf isEnabled {
    services.ntfy-sh = {
      enable = true;
      settings = lib.mkForce {
        base-url = "http://ntfy.yumeami.sh";
        behind-proxy = true;
        listen-http = ":${toString port}";

        upstream-base-url = "https://ntfy.sh";

        attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
        database-url = let
          pgPassword = getIn "postgresql.ntfy.password" (readJsonOrEmpty "${inputs.self}/secrets/crypt/secrets.json");
          pgHost = resolveDatabaseIP networkCfg.devices pgCfg.databases "ntfy";
          pgPort = 5600;
        in "postgres://ntfy:${pgPassword}@${pgHost}:${toString pgPort}/ntfy?sslmode=disable";

        auth-default-access = "deny-all";
        enable-login = true;
        require-login = true;

        auth-users = [
          "admin:$2b$10$Y0DfYjZ2uETxbNrexGvVF.LE3fBpJ.GBszccUGPqZAVQt9/bFsLR2:admin"
          "autobrr:$2b$10$Juz/FMxnIkDZz3RFirS7beuNo.H6YxY74ZWy2C6Fdle/r0TYbRIe.:user"
          "seerr:$2b$10$cv9DGn6TO62Gi99XYLpVEea8lnIPxB7jwFJwvtWiHQOJ57as0DqOi:user"
          "uptime-kuma:$2b$10$VwXFNTRxUbZKch7fFJAtsu.zdulpqHnxKBsvrotX8.7DmQPnyna12:user"
          "keitai:$2b$10$A1V0qHSQFZ0gU7COkZzeIOMd1NGxwa6JIBqTq/8dECz4MyyCL39V6:user"
        ];

        auth-access = [
          "autobrr:autobrr:write"
          "seerr:seerr:write"
          "uptime-kuma:uptime_kuma:write"
          "keitai:*:read-only"
        ];
      };
    };

    systemd.services.ntfy-sh.serviceConfig = {
      DynamicUser = mkForce false;
    };

    networking.firewall.allowedTCPPorts = [port];
  };
}
