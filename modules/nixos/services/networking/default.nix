{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkMerge mkOption types unique concatStringsSep;
  inherit (lib.${namespace}) getAttrByNamespace mkBoolOpt mkListOpt mkOpt mkOptAttrset mkOptionsWithNamespace mkRequiredOpt resolveHostIP resolveServiceEntries flattenHostServices;

  base = "${namespace}.services.networking";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      devices = mkOptAttrset (submodule {
        options = {
          ip = mkRequiredOpt str "The ip address of the device.";
          gateway = mkBoolOpt false "Whether the device should serve as a public gateway.";
        };
      }) {} "Mapping of device names to their hostnames and IPs.";
      network-services = mkOption {
        type = attrsOf (attrsOf (submodule {
          options = {
            port = mkRequiredOpt port "Local port of the service. If not specified, the module's default is used.";
            priority = mkOpt int 100 "Precedence when multiple hosts declare the same service. Lower values win; ties break alphabetically by hostname.";
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
      gateways = mkListOpt str [] "Names of devices which will serve as public gateways.";
    };

  config = {
    services.resolved = {
      enable = true;
      settings.Resolve.DNSStubListener = "no";
    };

    networking.nameservers = mkMerge [
      (cfg.network-services
        |> resolveServiceEntries "blocky"
        |> map (entry: resolveHostIP cfg.devices entry.host)
        |> unique)
      ["1.1.1.1" "8.8.8.8"]
    ];

    networking.firewall.extraCommands = let
      ports =
        cfg.network-services.${config.networking.hostName} or {}
        |> builtins.attrValues
        |> map (v: v.port)
        |> unique;
    in
      ports
      |> map (port: ''
        iptables -A nixos-fw -p tcp --dport ${toString port} -s 100.64.0.0/10 -j nixos-fw-accept
        iptables -A nixos-fw -p udp --dport ${toString port} -s 100.64.0.0/10 -j nixos-fw-accept
        ip6tables -A nixos-fw -p tcp --dport ${toString port} -s fd7a:115c:a1e0::/48 -j nixos-fw-accept
        ip6tables -A nixos-fw -p udp --dport ${toString port} -s fd7a:115c:a1e0::/48 -j nixos-fw-accept
      '')
      |> concatStringsSep "\n";
  };
}
