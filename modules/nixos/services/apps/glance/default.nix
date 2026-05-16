{
  config,
  inputs,
  lib,
  namespace,
  ...
} @ args: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService flattenHostServices getServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  isEnabled = hostHasService networkCfg.network-services hostName "dash";
  port = getServicePort networkServices "dash" 5150;
in {
  imports = [
    (import ./layout.nix args)
  ];

  config = mkIf isEnabled {
    services.glance = {
      enable = true;
      openFirewall = true;

      settings = {
        server = {
          host = "0.0.0.0";
          port = port;
          proxied = true;
          assets-path = "/etc/glance/assets";
        };

        branding = {
          favicon-url = "/assets/favicon.svg";
          app-icon-url = "/assets/favicon.svg";
        };
      };
    };

    environment.etc."glance/assets/favicon.svg" = {
      source = inputs.dotfiles + "/.assets/icons/favicon.svg";
      mode = "0755";
    };
  };
}
