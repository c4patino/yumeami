{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveDatabaseHost resolveDatabaseIP resolveServicePort waitForNetwork;
  inherit (config.networking) hostName;

  base = "${namespace}.services.storage.mariadb";
  mariadbCfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  mariadbHost = resolveDatabaseHost mariadbCfg.databases "seafile";
  mariadbIp = resolveDatabaseIP networkCfg.devices mariadbCfg.databases hostName "seafile";
  proxysqlPort = 5650;

  seafRoot = "/var/lib/seafile";
  ccnetDir = "${seafRoot}/ccnet";
  seahubDir = "${seafRoot}/seahub";
  seafileEnvFile = config.sops.secrets."environment-file/seafile".path;

  seahubSettings = pkgs.writeText "seahub_settings.py" ''
    FILE_SERVER_ROOT = 'http://${hostName}:${toString port}/seafhttp'
    MEDIA_ROOT = '${seahubDir}/media/'
    THUMBNAIL_ROOT = '${seahubDir}/thumbnail/'
    SERVICE_URL = 'http://${hostName}:${toString port}'
    CSRF_TRUSTED_ORIGINS = ["http://${hostName}:${toString port}"]
    TIME_ZONE = 'America/Chicago'

    with open('${seafRoot}/.seahubSecret') as f:
        SECRET_KEY = f.readline().rstrip()
  '';

  isEnabled = hostHasService networkCfg.network-services hostName "seafile";
  port = resolveServicePort networkCfg.network-services "seafile" 8080;
in {
  config = mkIf isEnabled {
    environment.etc."seafile/seahub_settings.py".source = seahubSettings;

    systemd.services.seahub = mkMerge [
      waitForNetwork
      {
        description = "Seafile Server Web Frontend";
        wantedBy = ["seafile.target"];
        partOf = ["seafile.target"];
        restartTriggers = [seahubSettings];
        environment = {
          PYTHONPATH = "${pkgs.seahub.pythonPath}:${pkgs.seahub}/thirdpart:${pkgs.seahub}";
          DJANGO_SETTINGS_MODULE = "seahub.settings";
          CCNET_CONF_DIR = ccnetDir;
          SEAFILE_CONF_DIR = "${seafRoot}/data";
          SEAFILE_CENTRAL_CONF_DIR = "/etc/seafile";
          SEAFILE_RPC_PIPE_PATH = "/run/seafile";
          SEAHUB_LOG_DIR = "/var/log/seafile";
          SEAFILE_MYSQL_DB_HOST = mariadbIp;
          SEAFILE_MYSQL_DB_PORT = toString proxysqlPort;
          SEAFILE_MYSQL_DB_USER = "seafile";
          SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile";
          SEAFILE_MYSQL_DB_CCNET_DB_NAME = "seafile-ccnet";
          SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seafile-hub";
          SEAFILE_SERVER_HOSTNAME = hostName;
          SEAFILE_SERVER_PROTOCOL = "http";
          INIT_SEAFILE_ADMIN_EMAIL = "c4patino@gmail.com";
        };
        serviceConfig = {
          User = "seafile";
          Group = "seafile";
          StateDirectory = "seafile";
          RuntimeDirectory = "seahub";
          LogsDirectory = "seafile";
          ConfigurationDirectory = "seafile";
          EnvironmentFile = seafileEnvFile;
          ExecStart = ''
            ${lib.getExe pkgs.seahub.python3.pkgs.gunicorn} seahub.wsgi:application \
            --name seahub \
            --workers 4 \
            --log-level=info \
            --preload \
            --timeout=1200 \
            --limit-request-line=8190 \
            --bind unix:/run/seahub/gunicorn.sock
          '';
        };
        preStart = ''
          mkdir -p ${seahubDir}/media
          for m in `find ${pkgs.seahub}/media/ -maxdepth 1 -not -name "avatars"`; do
            ln -sf $m ${seahubDir}/media/
          done
          if [ ! -e "${seafRoot}/.seahubSecret" ]; then
              (
                umask 377 &&
                ${lib.getExe pkgs.seahub.python3} ${pkgs.seahub}/tools/secret_key_generator.py > ${seafRoot}/.seahubSecret
              )
          fi
          if [ ! -f "${seafRoot}/seahub-setup" ]; then
              install -D -t ${seahubDir}/media/avatars/ ${pkgs.seahub}/media/avatars/default.png
              install -D -t ${seahubDir}/media/avatars/groups ${pkgs.seahub}/media/avatars/groups/default.png
              ${pkgs.seahub}/manage.py migrate
              ${pkgs.seahub}/manage.py createsuperuser --noinput --email=c4patino@gmail.com
              echo "${pkgs.seahub.version}-mysql" > "${seafRoot}/seahub-setup"
          fi
          if [ $(cat "${seafRoot}/seahub-setup" | cut -d"-" -f1) != "${pkgs.seahub.version}" ]; then
              ${pkgs.seahub}/manage.py migrate
              echo "${pkgs.seahub.version}-mysql" > "${seafRoot}/seahub-setup"
          fi
        '';
      }
      (mkIf (mariadbHost == hostName) {
        after = ["mysql.service"];
        requires = ["mysql.service"];
        serviceConfig.RestartSec = mkForce "1s";
      })
    ];
  };
}
