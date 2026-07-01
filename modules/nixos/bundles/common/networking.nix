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
          ip = "100.117.106.23";
        };
        arisu-windows = {
          ip = "100.72.5.107";
        };
        kokoro = {
          ip = "100.69.45.111";
        };
        kokoro-windows = {
          ip = "100.115.3.6";
        };
        chibi = {
          ip = "100.101.224.25";
        };
        shiori = {
          ip = "100.127.93.17";
          gateway = true;
        };
        tsuki = {
          ip = "100.71.23.30";
        };
        nas = {
          ip = "100.98.174.68";
        };
      };

      network-services = {
        chibi = {
          monitor = {
            port = 5200;
            internal = true;
          };
          ntfy = {
            port = 5201;
            public = true;
          };
          grafana = {
            port = 5500;
            internal = true;
          };
          prometheus = {
            port = 5501;
            internal = true;
          };
        };

        tsuki = {
          asciinema = {
            port = 4000;
            public = true;
            websocket.enable = true;
          };
          dash = {
            port = 5150;
            internal = true;
          };
          git = {
            port = 5300;
            internal = true;
            public = true;
          };
          ignis = {
            port = 5125;
            internal = true;
          };
          immich = {
            port = 2283;
            internal = true;
            websocket = {
              enable = true;
              path = "";
            };
          };
          jellyfin = {
            port = 8096;
            internal = true;
            public = true;
            websocket = {
              enable = true;
              path = "/socket";
            };
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

        shiori = {
          blocky = {
            port = 53;
          };
          unbound = {
            port = 54;
          };
          miasma = {
            port = 9999;
            internal = true;
            public = true;
          };
          seerr = {
            port = 5055;
            internal = true;
            public = true;
          };
          radarr = {
            port = 7878;
            internal = true;
          };
          sonarr = {
            port = 8989;
            internal = true;
          };
          lidarr = {
            port = 8686;
            internal = true;
          };
          bazarr = {
            port = 6767;
          };
          prowlarr = {
            port = 9696;
          };
          autobrr = {
            port = 7474;
          };
          qbittorrent = {
            port = 9000;
            internal = true;
          };
        };
      };
    };
  };
}
