{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  base = "${namespace}.bundles.homelab";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    ${namespace}.services.storage = {
      postgresql = {
        databases = {
          shiori = [
            "autobrr"
            "bazarr"
            "lidarr"
            "lidarr-log"
            "prowlarr"
            "prowlarr-log"
            "qui"
            "radarr"
            "radarr-log"
            "seerr"
            "sonarr"
            "sonarr-log"
          ];
          tsuki = [
            "asciinema"
            "forgejo"
            "grafana"
            "immich"
            "ntfy"
            "terraform"
            "vaultwarden"
          ];
        };
      };

      mariadb = {
        databases = {
          tsuki = [
            "seafile"
            "seafile-hub"
            "seafile-ccnet"
          ];
        };
      };

      syncthing = {
        enable = true;
        devices = {
          arisu = "7W2TB7D-VZZEDAP-Q2LTH7S-LUF3JOC-472P4FX-ZUQX4SG-CLPTTK6-RVUP6QQ";
          kokoro = "7ADRQXW-IB3IMNR-QCT4EXQ-4BON25I-4EFPOW6-AVJNUZK-TEDMDZQ-RH37RAB";
          chibi = "HBLTAF3-GJ7G6XS-ER6IMAZ-CY2UI7S-6BG3N3S-GF4TDIC-7USNXW7-M6TWJQU";
          shiori = "BT76CBG-CZLKV2Q-S2ZGSPB-OC3KE66-HAHLDZ6-5W7GOOI-YNF6AXO-FU3N6AQ";
          tsuki = "K7LWUU4-JHFZJ7Z-5XZHIVS-OR2XMGR-SVKEGJM-D6XGB4W-NN4Z7EI-LTH7CAB";
        };
        shares = {
          shared = ["arisu" "kokoro" "chibi" "shiori"];
        };
      };
    };
  };
}
