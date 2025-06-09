{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.networking.blocky";
  cfg = getAttrByNamespace config base;
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  port = 53;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "blocky";
    };

  config = mkIf cfg.enable {
    services.blocky = {
      enable = true;
      settings = {
        connectIPVersion = "v4";

        ports = {
          dns = 53;
          tls = 853;
        };

        upstreams = {
          strategy = "strict";
          timeout = "30s";
          init.strategy = "fast";
          groups.default = [
            "tcp+udp:127.0.0.1:54"
          ];
        };
        blocking = {
          loading = {
            strategy = "fast";
            concurrency = 8;
            refreshPeriod = "4h";
          };
          blackLists = {
            ads = [
              "https://blocklistproject.github.io/Lists/ads.txt"
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              "https://adaway.org/hosts.txt"
              "https://v.firebog.net/hosts/AdguardDNS.txt"
              "https://v.firebog.net/hosts/Admiral.txt"
              "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
              "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
              "https://v.firebog.net/hosts/Easylist.txt"
              "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
              "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
              "https://raw.githubusercontent.com/AdGoBye/AdGoBye-Blocklists/main/AGBBase.toml"
              "https://raw.githubusercontent.com/AdGoBye/AdGoBye-Blocklists/main/AGBCommunity.toml"
              "https://raw.githubusercontent.com/AdGoBye/AdGoBye-Blocklists/main/AGBUpsell.toml"
              "https://raw.githubusercontent.com/AdGoBye/AdGoBye-Blocklists/main/AGBSupporters.toml"
            ];
            tracking = [
              "https://v.firebog.net/hosts/Easyprivacy.txt"
              "https://v.firebog.net/hosts/Prigent-Ads.txt"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
              "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
              "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
            ];
            malicious = [
              "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
              "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
              "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
              "https://v.firebog.net/hosts/Prigent-Crypto.txt"
              "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
              "https://v.firebog.net/hosts/RPiList-Phishing.txt"
              "https://v.firebog.net/hosts/RPiList-Malware.txt"
            ];
            misc = [
              "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"
              "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-only/hosts"
            ];
            catchall = [
              "https://big.oisd.nl/domainswild"
            ];
          };
          whiteLists = let
            customWhitelist = pkgs.writeText "misc.txt" ''
              *.yumeami.sh
            '';
          in {
            ads = [
              "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
              "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/optional-list.txt"
            ];
            misc = [customWhitelist];
          };
          clientGroupsBlock = {
            default = [
              "ads"
              "tracking"
              "malicious"
              "misc"
              "catchall"
            ];
          };
        };

        customDNS = {
          domainMapping =
            networkCfg.network-services
            |> mapAttrsToList (name: svc: {
              name = "${name}.yumeami.sh";
              value = resolveHostIP networkCfg.devices svc.host;
            })
            |> listToAttrs;
        };
      };
    };

    networking.firewall.allowedTCPPorts = [port 4000];
    networking.firewall.allowedUDPPorts = [port];
  };
}
