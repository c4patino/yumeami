{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkPersistRootDir;
  base = "${namespace}.services.storage.redis";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "the fleet redis cache on 127.0.0.1:6379";
  };

  config = mkIf cfg.enable {
    services.redis.servers."" = {
      enable = true;
      bind = "127.0.0.1";
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/redis" "700")
    ];
  };
}
