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
    ${namespace}.services.networking = {
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
        arisu = {
          jellyfin = {
            port = 8096;
            internal = true;
          };
          ombi = {
            port = 5000;
            internal = true;
          };
          radarr = {
            port = 7878;
          };
          sonarr = {
            port = 8989;
          };
          lidarr = {
            port = 8686;
          };
          bazarr = {
            port = 6767;
          };
          prowlarr = {
            port = 9696;
          };
          miasma = {
            port = 9999;
            internal = true;
            public = true;
          };
        };

        chibi = {
          monitor = {
            port = 5200;
            internal = true;
          };
          ntfy = {
            port = 5201;
            public = true;
          };
          blocky = {
            port = 53;
          };
        };

        shiori = {
          dash = {
            port = 5150;
            internal = true;
          };
          git = {
            port = 5300;
            public = true;
          };
          grafana = {
            port = 5500;
            internal = true;
          };
          paste = {
            port = 5100;
            public = true;
          };
          vault = {
            port = 5400;
            public = true;
          };
          woodpecker = {
            port = 5301;
            internal = true;
          };
        };
      };

      unbound.dnsHost = "shiori";
    };
  };
}
