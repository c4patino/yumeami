{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) concatStringsSep getAttr hasAttr mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkPersistRootDir;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.mariadb";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf (hasAttr hostName cfg.databases && cfg.databases.${hostName} != []) (let
    hostDatabases = getAttr hostName cfg.databases;
  in {
    systemd.services.mariadb-backup = {
      description = "Backup MariaDB databases";
      after = ["mysql.service"];
      requires = ["mysql.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = let
          backupDir = "/var/backup/mariadb";
          dumpCmd =
            hostDatabases
            |> map (db: ''
              ${pkgs.mariadb}/bin/mariadb-dump -u root --single-transaction --routines --triggers ${db} | ${pkgs.zstd}/bin/zstd -T0 -1 > ${backupDir}/${db}-$(date +%Y%m%d).sql.zst
            '')
            |> concatStringsSep "\n";
        in
          pkgs.writeShellScript "mariadb-backup.sh" ''
            mkdir -p ${backupDir}
            ${dumpCmd}
            find ${backupDir} -name "*.sql.zst" -mtime +7 -delete
          '';
      };
    };

    systemd.timers.mariadb-backup = {
      description = "Daily MariaDB backup";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "*-*-* 23:00:00";
        RandomizedDelaySec = "15min";
        Persistent = true;
      };
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/backup/mariadb" "700")
    ];
  });
}
