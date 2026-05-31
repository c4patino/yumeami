{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.networking.ddclient";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "ddclient";
  };

  config = mkIf cfg.enable {
    services.ddclient = {
      enable = true;
      ssl = true;
      verbose = true;

      zone = "cpatino.com";
      protocol = "cloudflare";
      passwordFile = config.sops.secrets."cloudflare/ddclient-token".path;

      interval = "5m";

      domains = [
        "*.cpatino.com"
      ];
    };

    sops.secrets = {
      "cloudflare/ddclient-token" = {};
    };
  };
}
