{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) filterAttrs flatten listToAttrs mapAttrsToList mkIf;
  inherit (lib.${namespace}) flattenHostServices getAttrByNamespace hostHasService resolveGatewayHost resolveHostIP resolveServicePort;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  gatewayHost = resolveGatewayHost networkCfg.devices;

  isEnabled = hostHasService networkCfg.registry hostName "blocky";
  port = resolveServicePort networkCfg.registry "blocky" 53;
  unboundPort = (networkCfg.registry.${hostName}.unbound or {}).port or 54;
in {
  config = mkIf isEnabled {
    assertions = [
      {
        assertion = hostHasService networkCfg.registry hostName "unbound";
        message = "Host '${hostName}' declares blocky but not unbound; blocky forwards to the local unbound instance, so both must be co-hosted.";
      }
    ];

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
            "tcp+udp:127.0.0.1:${toString unboundPort}"
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

                api.ipify.org
                api6.ipify.org
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
                networkCfg.registry
                |> flattenHostServices
                |> filterAttrs (_: svc: svc.internal)
                |> mapAttrsToList (name: svc: {
                  name = "${name}.yumeami.sh";
                  value = resolveHostIP networkCfg.devices svc.host;
                })
              )
              (
                networkCfg.registry
                |> flattenHostServices
                |> filterAttrs (_: svc: svc.public)
                |> mapAttrsToList (name: svc: {
                  name = "${name}.cpatino.com";
                  value = resolveHostIP networkCfg.devices gatewayHost;
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
