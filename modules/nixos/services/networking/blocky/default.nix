{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mapAttrsToList listToAttrs filterAttrs flatten;
  inherit (lib.${namespace}) getAttrByNamespace resolveHostIP flattenHostServices hostHasService getServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  isEnabled = hostHasService networkCfg.network-services hostName "blocky";
  port = getServicePort networkServices "blocky" 53;
in {
  config = mkIf isEnabled {
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
          allowlists = {
            catchall = [
              (pkgs.writeText "homelab.txt" ''
                *.yumeami.sh
                *.cpatino.com
              '')
            ];
          };
          denylists = {
            catchall = [
              "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/ultimate.txt"
            ];
          };
          clientGroupsBlock = {
            default = [
              "catchall"
            ];
          };
        };

        customDNS = {
          customTTL = "1h";
          mapping =
            [
              (
                networkServices
                |> filterAttrs (_: svc: svc.internal)
                |> mapAttrsToList (name: svc: {
                  name = "${name}.yumeami.sh";
                  value = resolveHostIP networkCfg.devices svc.host;
                })
              )
              (
                networkServices
                |> filterAttrs (_: svc: svc.public)
                |> mapAttrsToList (name: svc: {
                  name = "${name}.cpatino.com";
                  value = resolveHostIP networkCfg.devices hostName;
                })
              )
            ]
            |> flatten
            |> listToAttrs;
        };
      };
    };

    networking.firewall = {
      allowedTCPPorts = [port];
      allowedUDPPorts = [port];
    };
  };
}
