{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) concatStringsSep mkDefault mkIf mkMerge mkOption types unique;
  inherit (lib.${namespace}) getAttrByNamespace isGateway mapTargetIP mkBoolOpt mkOpt mkOptAttrset mkOptionsWithNamespace mkRequiredOpt mkTailscaleFirewallRule resolveDevice resolveServiceEntries;
  inherit (config.networking) hostName;

  base = "${namespace}.services.networking";
  cfg = getAttrByNamespace config base;

  gatewayCfg = {
    raw = {};
    cloudflare = {
      cloudflared.enable = true;
    };
  };
in {
  options = with types;
    mkOptionsWithNamespace base {
      devices = mkOptAttrset (submodule {
        options = {
          ip = mkRequiredOpt str "The ip address of the device.";
          gateway = mkOpt (submodule {
            options = {
              enable = mkBoolOpt false "Whether the device should serve as a public gateway.";
              mode = mkOpt (enum ["cloudflare" "raw"]) "raw" "How the gateway exposes services to the internet: raw port forwarding or a Cloudflare tunnel. Raw mode only marks the host as the gateway and enables no extra ingress service.";
            };
          }) {} "Public gateway configuration for the device.";
        };
      }) {} "Mapping of device names to their hostnames and IPs.";
      network-services = mkOption {
        type = attrsOf (attrsOf (submodule {
          options = {
            port = mkRequiredOpt port "Local port of the service. If not specified, the module's default is used.";
            priority = mkOpt int 256 "Precedence when multiple hosts declare the same service. Lower values win; ties break alphabetically by hostname.";
            public = mkBoolOpt false "Whether the service should be publicly accessible over *.cpatino.com.";
            internal = mkBoolOpt false "Whether the service should be internally accessible over *.yumeami.sh.";
            websocket = mkOpt (submodule {
              options = {
                enable = mkBoolOpt false "Whether to enable websocket endpoints for the service.";
                path = mkOpt str "/ws" "WebSocket path prefix for the service.";
              };
            }) {} "WebSocket configuration for the service.";
          };
        }));
        default = {};
        description = "Mapping of hosts to their services: networking-services.<host>.<service> = { port, internal, public }.";
      };
    };

  config = mkMerge [
    {
      services = {
        resolved = {
          enable = true;
          settings.Resolve.DNSStubListener = "no";
        };

        timesyncd = {
          enable = mkDefault true;
          servers = [
            "162.159.200.1"
            "162.159.200.123"
          ];
        };
      };

      networking = {
        nameservers =
          cfg.network-services
          |> resolveServiceEntries "blocky"
          |> map (entry: mapTargetIP cfg.devices entry.host hostName)
          |> unique;

        firewall.extraCommands =
          cfg.network-services.${config.networking.hostName} or {}
          |> builtins.attrValues
          |> map (v: v.port)
          |> unique
          |> map (port: mkTailscaleFirewallRule port ["tcp" "udp"])
          |> concatStringsSep "\n";
      };
    }

    (mkIf (isGateway cfg.devices hostName) {
      ${namespace}.services.networking = let
        gatewayMode = (resolveDevice cfg.devices hostName).gateway.mode;
      in
        gatewayCfg
        |> builtins.attrNames
        |> map (mode: mkIf (gatewayMode == mode) gatewayCfg.${mode})
        |> mkMerge;
    })
  ];
}
