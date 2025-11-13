{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  base = "${namespace}.bundles.common";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    ${namespace} = {
      services = {
        networking = {
          devices = {
            arisu = {
              IP = "100.117.106.23";
            };
            arisu-windows = {
              IP = "100.72.5.107";
            };
            kokoro = {
              IP = "100.69.45.111";
            };
            kokoro-windows = {
              IP = "100.115.3.6";
            };
            chibi = {
              IP = "100.101.224.25";
            };
            shiori = {
              IP = "100.127.93.17";
            };
          };

          network-services = {
            monitor = {
              host = "chibi";
              port = 5200;
            };
            ntfy = {
              host = "chibi";
              port = 5201;
              public = true;
            };

            dash = {
              host = "shiori";
              port = 5150;
            };
            git = {
              host = "shiori";
              port = 5300;
              public = true;
            };
            grafana = {
              host = "shiori";
              port = 5500;
            };
            paste = {
              host = "shiori";
              port = 5100;
              public = true;
            };
            vault = {
              host = "shiori";
              port = 5400;
              public = true;
            };
            woodpecker = {
              host = "shiori";
              port = 5301;
            };
          };

          unbound.dnsHost = "chibi";
        };
      };
    };
  };
}
