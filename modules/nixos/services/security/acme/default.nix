{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace isGateway mkPersistDir;
  inherit (config.networking) hostName;

  cfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  config = mkIf (isGateway cfg.devices hostName) {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "c4patino@gmail.com";

        dnsProvider = "cloudflare";
        credentialFiles = let
          inherit (config.sops) secrets;
        in {
          CF_DNS_API_TOKEN_FILE = secrets."cloudflare/acme-token".path;
          CF_ZONE_API_TOKEN_FILE = secrets."cloudflare/acme-token".path;
        };
      };
      certs = {
        "wildcard_cpatino_com" = {
          domain = "*.cpatino.com";
        };
      };
    };

    users.users.wwwrun.extraGroups = ["acme"];

    sops.secrets = {
      "cloudflare/acme-token" = {};
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "acme" "/var/lib/acme" "750")
    ];
  };
}
