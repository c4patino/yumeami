{
  lib,
  config,
  ...
}: let
  inherit (lib) types;
  port = 54;
in {
  options.unbound = {
    enable = lib.mkEnableOption "unbound";
    dnsHost = lib.mkOption {
      type = types.nullOr types.str;
      description = "The DNS hostname to resolve";
      default = null;
    };
  };

  config = lib.mkIf config.unbound.enable {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          verbosity = 1;

          interface = "0.0.0.0";
          port = port;

          do-ip4 = true;
          do-ip6 = true;
          do-udp = true;
          do-tcp = true;

          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          edns-buffer-size = 1232;

          num-threads = 2;

          so-rcvbuf = "1m";

          hide-identity = true;
          hide-version = true;

          cache-min-ttl = 3600;
          cache-max-ttl = 86400;
          prefetch = true;

          access-control = [
            "127.0.0.0/8 allow"
            "0.0.0.0/0 allow"
            "::1 allow"
            "100.64.0.0/10 allow"
            "fd7a:115c:a1e0::/48 allow"
          ];

          private-address = [
            "192.168.0.0/16"
            "169.254.0.0/16"
            "172.16.0.0/12"
            "10.0.0.0/8"
            "fd00::/8"
            "fe80::/10"
          ];
        };

        forward-zone = [
          {
            name = ".";
            forward-addr = [
              "1.1.1.1@853"
              "8.8.8.8@853"
            ];
            forward-tls-upstream = true;
          }
          {
            name = "ts.net";
            forward-addr = [
              "100.100.100.100"
            ];
          }
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [port 853];
    networking.firewall.allowedUDPPorts = [port 853];
  };
}
