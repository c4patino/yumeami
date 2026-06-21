{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkOpt mkListOpt;
  base = "${namespace}.services.networking.ddclient";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "ddclient";
      zone = mkOpt str "" "domain zone to enable ddclient for";
      domains = mkListOpt str [] "list of sub domains within zone to manage";
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
