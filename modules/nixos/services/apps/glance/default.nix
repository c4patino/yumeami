{
  config,
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
        };
      };
    };
  };
}
