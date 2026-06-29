{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.bundles.server";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "server bundle";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      services = {
        networking = {
          httpd = enabled;
        };

        security = {
          fail2ban = enabled;
        };
      };
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
    };
  };
}
