{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  cfg = getAttrByNamespace config "${namespace}.services.networking.httpd";
in {
  config = mkIf cfg.enable {
    services.fail2ban.jails = {
      # apache-auth: catches 401 auth failures from ALL proxied services
      apache-auth = {
        settings = {
          enabled = true;
          filter = "apache-auth";
          logpath = "/var/log/httpd/error-*.log*";
          backend = "auto";
          maxretry = 5;
          findtime = 600;
          bantime = "1h";
        };
      };

      # apache-badbots: known malicious bot scanners
      apache-badbots = {
        settings = {
          enabled = true;
          filter = "apache-badbots";
          logpath = "/var/log/httpd/access-*.log*";
          backend = "auto";
          maxretry = 5;
          findtime = 600;
          bantime = "1h";
        };
      };

      # apache-noscript: script/exploit scanning
      apache-noscript = {
        settings = {
          enabled = true;
          filter = "apache-noscript";
          logpath = "/var/log/httpd/access-*.log*";
          backend = "auto";
          maxretry = 5;
          findtime = 600;
          bantime = "1h";
        };
      };

      # apache-nohome: home directory traversal scans
      apache-nohome = {
        settings = {
          enabled = true;
          filter = "apache-nohome";
          logpath = "/var/log/httpd/access-*.log*";
          backend = "auto";
          maxretry = 5;
          findtime = 600;
          bantime = "1h";
        };
      };

      # apache-overflows: buffer overflow / request smuggling attempts
      apache-overflows = {
        settings = {
          enabled = true;
          filter = "apache-overflows";
          logpath = "/var/log/httpd/error-*.log*";
          backend = "auto";
          maxretry = 5;
          findtime = 600;
          bantime = "1h";
        };
      };
    };
  };
}
