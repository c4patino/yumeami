{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkBoolOpt mkOptionsWithNamespace mkPersistRootDir;
  base = "${namespace}.services.networking.tailscale";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Tailscale";

    recovery = {
      enable = mkBoolOpt false "Whether to periodically check Tailscale control-plane connectivity.";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
    };

    systemd = mkIf cfg.recovery.enable {
      services.tailscale-recovery = let
        tailscaleRecovery = import ./recovery.nix {
          inherit pkgs;
        };
      in {
        description = "Recover stuck Tailscale control-plane connectivity";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${tailscaleRecovery}/bin/tailscale-recovery";
        };
      };

      timers.tailscale-recovery = {
        description = "Periodically check Tailscale control-plane connectivity";
        wantedBy = ["timers.target"];

        timerConfig = {
          OnBootSec = "5min";
          OnUnitActiveSec = "5min";
        };
      };
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/tailscale" "700")
    ];
  };
}
