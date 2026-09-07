{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveDatabaseHost resolveDatabaseIP waitForNetwork;
  inherit (config.networking) hostName;

  base = "${namespace}.services.storage.mariadb";
  mariadbCfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "seafile";
  mariadbHost = resolveDatabaseHost mariadbCfg.databases "seafile-ccnet";
  mariadbIp = resolveDatabaseIP networkCfg.devices mariadbCfg.databases hostName "seafile-ccnet";
  proxysqlPort = 5650;

  seafRoot = "/var/lib/seafile";
  ccnetDir = "${seafRoot}/ccnet";

  confDir = pkgs.runCommand "seafile-conf" {} ''
    mkdir -p $out
    cat > $out/ccnet.conf << EOF
    [Database]
    ENGINE = mysql
    HOST = ${mariadbIp}
    PORT = ${toString proxysqlPort}
    DB = seafile-ccnet
    CONNECTION_CHARSET = utf8
    EOF

    cat > $out/seafile.conf << EOF
    [database]
    type = mysql
    host = ${mariadbIp}
    port = ${toString proxysqlPort}
    db_name = seafile
    connection_charset = utf8

    [fileserver]
    port = 8082
    host = ipv4:127.0.0.1
    EOF
  '';
in {
  config = mkIf isEnabled {
    systemd.services.seaf-gc = mkMerge [
      waitForNetwork
      {
        description = "Seafile storage garbage collection";
        conflicts = ["seaf-server.service" "seahub.service"];
        onSuccess = ["seaf-server.service" "seahub.service"];
        onFailure = ["seaf-server.service" "seahub.service"];
        startAt = ["Sun 03:00:00"];
        serviceConfig = {
          User = "seafile";
          Group = "seafile";
          StateDirectory = "seafile";
          RuntimeDirectory = "seafile";
          LogsDirectory = "seafile";
          ConfigurationDirectory = "seafile";
          Type = "oneshot";
        };
        script = ''
          if [ ! -f "${seafRoot}/server-setup" ]; then
              echo "Server not setup yet, GC not needed" >&2
              exit
          fi
          ${pkgs.seafile-server}/bin/seafserv-gc \
            -F ${confDir} \
            -c ${ccnetDir} \
            -d ${seafRoot}/data \
            --rm-fs
        '';
      }
      (mkIf (mariadbHost == hostName) {
        after = ["mysql.service"];
        requires = ["mysql.service"];
      })
    ];

    systemd.timers.seaf-gc = {
      timerConfig = {
        Persistent = true;
      };
    };
  };
}
