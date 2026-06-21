{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services hostName "unbound";
  port = resolveServicePort networkCfg.network-services "unbound" 54;
in {
  config = mkIf isEnabled {
    services.unbound = {
      enable = true;
      settings = {
        server = {
          verbosity = 1;

          interface = "127.0.0.1";
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
            "::1 allow"
            "100.64.0.0/10 allow"
            "fd7a:115c:a1e0::/48 allow"
          ];

          private-address = [
            "10.0.0.0/8" # private LAN (class A)
            "172.16.0.0/12" # private LAN (class B)
            "192.168.0.0/16" # private LAN (class C)
            "169.254.0.0/16" # link-local
            "fd00::/8" # private LAN
            "fe80::/10" # link-local
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
  };
}
