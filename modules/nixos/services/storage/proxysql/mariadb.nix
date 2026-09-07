{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) getAttr hasAttr mkIf;
  inherit (lib.${namespace}) getAttrByNamespace getIn mkDatabaseUtils readJsonOrEmpty;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.mariadb";
  cfg = getAttrByNamespace config base;

  port = 5650;
  mariadbPort = 5651;
in {
  config = mkIf (hasAttr hostName cfg.databases && cfg.databases.${hostName} != []) (let
    databases = getAttr hostName cfg.databases;
    db = mkDatabaseUtils databases;
    secrets = readJsonOrEmpty "${inputs.self}/secrets/crypt/mariadb.json";
  in {
    ${namespace}.services.storage.proxysql = {
      settings = {
        mysql_variables.interfaces = "0.0.0.0:${toString port}";

        mysql_servers = [
          {
            address = "127.0.0.1";
            port = mariadbPort;
            hostgroup = 0;
          }
        ];

        mysql_users =
          db.uniquePrefixes
          |> map (prefix: {
            username = prefix;
            password = getIn "${prefix}.password" secrets;
          });
      };
    };

    systemd.services.proxysql = {
      after = [
        "mysql.service"
        "mariadb-setup.service"
      ];
      requires = [
        "mysql.service"
        "mariadb-setup.service"
      ];
      serviceConfig.ExecStartPost = let
        # systemd reports a forking service as active as soon as the daemon
        # forks, but ProxySQL only starts accepting connections slightly later.
        # Without this gate, dependents ordered with `after = proxysql` race
        # into that window and fail with ERROR 2002. `mariadb-admin ping`
        # exits 0 as soon as the server answers the handshake, even when it
        # rejects our credentials.
        ready = pkgs.writeShellScript "proxysql-ready" ''
          for ((i = 0; i < 30; i++)); do
            if ${pkgs.mariadb.client}/bin/mariadb-admin --connect-timeout=1 --host=127.0.0.1 --port=${toString port} ping >/dev/null 2>&1; then
              exit 0
            fi
            ${pkgs.coreutils}/bin/sleep 0.5
          done
          echo "proxysql is not accepting connections on 127.0.0.1:${toString port}" >&2
          exit 1
        '';
      in ready;
    };

    networking.firewall.allowedTCPPorts = [port];
  });
}
