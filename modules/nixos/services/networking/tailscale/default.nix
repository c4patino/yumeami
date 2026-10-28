{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) concatStringsSep escapeShellArg mapAttrsToList mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkBoolOpt mkOpt mkOptionsWithNamespace mkPersistRootDir mkRequiredOpt;
  base = "${namespace}.services.networking.tailscale";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    ./recovery.nix
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Tailscale";

    recovery = {
      enable = mkBoolOpt false "Whether to periodically check Tailscale control-plane connectivity.";
    };

    funnel = {
      enable = mkBoolOpt false "Whether to expose local services to the internet with Tailscale Funnel.";

      endpoints = mkOpt (lib.types.attrsOf (lib.types.submodule {
        options = {
          listenPort = mkRequiredOpt lib.types.port "Public HTTPS port to serve the endpoint on. Tailscale Funnel only supports 443, 8443, and 10000.";
          target = mkRequiredOpt lib.types.str "Local backend URL to proxy to, e.g. \"http://127.0.0.1:80\".";
        };
      })) {} "Funnel endpoints keyed by name.";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
    };

    systemd.services.tailscale-funnel = mkIf cfg.funnel.enable {
      description = "Configure Tailscale Funnel endpoints";
      wantedBy = ["tailscaled.service"];
      wants = ["tailscaled.service"];
      after = ["tailscaled.service"];
      partOf = ["tailscaled.service"];
      startLimitIntervalSec = 0;
      path = [
        config.services.tailscale.package
        pkgs.coreutils
        pkgs.jq
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "10s";
      };
      script = ''
        set -euo pipefail

        state=Unknown
        for _ in $(seq 1 120); do
          state="$(tailscale status --json --peers=false 2>/dev/null | jq -r '.BackendState // "Unknown"' || echo Unknown)"
          if [ "$state" = "Running" ]; then
            break
          fi
          sleep 1
        done

        if [ "$state" != "Running" ]; then
          echo "tailscaled is not running (state: $state)" >&2
          exit 1
        fi

        tailscale funnel reset

        ${concatStringsSep "\n" (mapAttrsToList (_: endpoint: ''
            tailscale funnel --bg --yes --https=${toString endpoint.listenPort} ${escapeShellArg endpoint.target}
          '')
          cfg.funnel.endpoints)}
      '';
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/tailscale" "700")
    ];
  };
}
