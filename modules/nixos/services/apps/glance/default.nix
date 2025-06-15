{
  config,
  inputs,
  lib,
  namespace,
  ...
} @ args: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.glance";
  cfg = getAttrByNamespace config base;

  port = 5150;
in {
  imports = [
    (import ./layout.nix args)
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "glance";
  };

  config = mkIf cfg.enable {
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
      source = "${inputs.dotfiles}/assets/icons/favicon.svg";
      mode = "0755";
    };
  };
}
