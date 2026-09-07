{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) getAttr hasAttr mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  inherit (config.networking) hostName;
  base = "${namespace}.services.storage.postgresql";
  cfg = getAttrByNamespace config base;

  port = 5601;
in {
  config = mkIf (hasAttr hostName cfg.databases) {
    services.postgresqlBackup = {
      enable = true;
      databases =
        cfg.databases
        |> getAttr hostName;
      compression = "zstd";
      compressionLevel = 4;
      pgdumpOptions = "-C --port=${toString port}";
      startAt = "*-*-* 23:00:00";
    };
  };
}
