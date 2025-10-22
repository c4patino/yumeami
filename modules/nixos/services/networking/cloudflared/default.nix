{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.networking.cloudflared";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "cloudflared";
  };

  config = mkIf cfg.enable {
    services.cloudflared = {
      enable = true;
      tunnels = let
        inherit (config.sops) secrets;
      in {
        "0c162933-a9bd-4f44-9086-0794ceab9034" = {
          certificateFile = secrets."cloudflare/tunnel/certificate".path;
          credentialsFile = secrets."cloudflare/tunnel/credentials".path;

          # ingress = {
          #   "*.cpatino.com" = "http://localhost:80";
          # };

          default = "http://localhost:80";
        };
      };
    };
  };
}
