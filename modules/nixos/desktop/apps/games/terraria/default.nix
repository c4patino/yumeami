{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkOpt mkNullableOpt mkPersistRootDir;
  base = "${namespace}.desktop.apps.games.terraria";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "terraria";
      size = mkOpt str "large" "port for the server";
      port = mkOpt int 7777 "port for the server";
      password = mkNullableOpt str "" "password for the server";
    };

  config = mkIf cfg.enable {
    services.terraria = {
      enable = true;
      secure = true;
      dataDir = "/srv/terraria";

      openFirewall = true;

      autoCreatedWorldSize = cfg.size;
      password = cfg.password;
      port = cfg.port;
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/srv/terraria")
    ];
  };
}
