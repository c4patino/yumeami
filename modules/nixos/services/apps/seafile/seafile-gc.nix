{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) getExe' mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveDatabaseHost resolveDatabaseIP resolveServicePort waitForNetwork;
  inherit (config.networking) hostName;

  base = "${namespace}.services.apps.seafile";
  cfg = getAttrByNamespace config base;
  mariadbBase = "${namespace}.services.storage.mariadb";
  mariadbCfg = getAttrByNamespace config mariadbBase;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "seafile";
  mariadbHost = resolveDatabaseHost mariadbCfg.databases "seafile-ccnet";
  mariadbIp = resolveDatabaseIP networkCfg.devices mariadbCfg.databases hostName "seafile-ccnet";
  proxysqlPort = 5650;

  confDir = pkgs.seafile-server.mkConf {
    host = mariadbIp;
    port = proxysqlPort;
    fileServerPort = (resolveServicePort networkCfg.network-services "seafile" 8080) + 1;
  };
in {
  config = mkIf isEnabled {
    systemd.services.seafile-gc = mkMerge [
      {
        description = "Seafile storage garbage collection";

        conflicts = ["seafile-server.service" "seahub.service"];
        onSuccess = ["seafile-server.service" "seahub.service"];
        onFailure = ["seafile-server.service" "seahub.service"];

        serviceConfig = let
          inherit (config.users.users) seafile;
        in {
          User = seafile.name;
          Group = seafile.group;
          StateDirectory = "seafile";
          EnvironmentFile = config.sops.secrets."environment-file/seafile".path;
          Type = "oneshot";
        };
        script = ''
          if [ ! -f "${cfg.root}/server-setup" ]; then
              echo "Server not setup yet, GC not needed" >&2
              exit
          fi

          ${getExe' pkgs.seafile-server "seafserv-gc"} \
            -F ${confDir} \
            -c ${cfg.root}/ccnet \
            -d ${cfg.root}/data \
            --rm-fs
        '';
      }
      waitForNetwork
      (mkIf (mariadbHost == hostName) {
        after = ["mysql.service" "proxysql.service"];
        requires = ["mysql.service" "proxysql.service"];
      })
    ];

    systemd.timers.seafile-gc = {
      description = "Weekly Seafile garbage collection";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "Sun 00:00:00";
        Persistent = true;
      };
    };
  };
}
