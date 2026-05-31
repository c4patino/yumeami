{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.networking.ddclient";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "ddclient";
      zone = mkOption {
        type = str;
        description = "domain zone to enable ddclient for";
      };
      domains = mkOption {
        type = listOf str;
        description = "list of sub domains within zone to manage";
      };
    };

  config = mkIf cfg.enable {
    services.ddclient = {
      enable = true;
      ssl = true;
      verbose = true;

      protocol = "cloudflare";
      passwordFile = config.sops.secrets."cloudflare/ddclient-token".path;

      interval = "5m";

      inherit (cfg) domains zone;
    };

    sops.secrets = {
      "cloudflare/ddclient-token" = {};
    };
  };
}
