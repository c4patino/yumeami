{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.games.terraria";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "terraria";
      size = mkOption {
        type = str;
        default = "large";
        description = "port for the server";
      };
      port = mkOption {
        type = int;
        default = 7777;
        description = "port for the server";
      };
      password = mkOption {
        type = nullOr str;
        default = "";
        description = "password for the server";
      };
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

    ${namespace}.services.storage.impermanence.folders = ["/srv/terraria"];
  };
}
