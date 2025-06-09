{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
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
            kokoro = {
              IP = "100.69.45.111";
            };
            chibi = {
              IP = "100.101.224.25";
            };
            shiori = {
              IP = "100.127.93.17";
            };
          };
          network-services = {
            paste = {
              host = "arisu";
              port = 5100;
            };
            dash = {
              host = "arisu";
              port = 5150;
            };

            monitor = {
              host = "chibi";
              port = 5200;
            };
            ntfy = {
              host = "chibi";
              port = 5201;
            };

            git = {
              host = "shiori";
              port = 5300;
            };
            vault = {
              host = "shiori";
              port = 5400;
            };
            grafana = {
              host = "shiori";
              port = 5500;
            };
          };
          unbound.dnsHost = "chibi";
        };
      };
    };
  };
}
