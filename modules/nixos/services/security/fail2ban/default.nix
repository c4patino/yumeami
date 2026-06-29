{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.security.fail2ban";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "fail2ban";
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;

      bantime = "1h";

      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "100.64.0.0/10"
        "192.168.0.0/16"
        "172.16.0.0/12"
        "fd00::/8"
        "fe80::/10"
      ];

      bantime-increment = {
        enable = true;
        maxtime = "1w";
        overalljails = true;
        rndtime = "5m";
      };
    };
  };
}
