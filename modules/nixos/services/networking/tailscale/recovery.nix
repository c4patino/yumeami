{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace;
  base = "${namespace}.services.networking.tailscale";
  cfg = getAttrByNamespace config base;

  tailscaleRecovery = pkgs.writeShellScriptBin "tailscale-recovery" ''
    set -euo pipefail

    delay=1

    for attempt in {1..8}; do
      if output=$(timeout 25s ${pkgs.tailscale}/bin/tailscale netcheck 2>&1); then
        exit 0
      fi

      if ! printf '%s\n' "$output" | grep -Eqi 'Failed to fetch a DERP map|context deadline exceeded|Client.Timeout exceeded|timed out'; then
        echo "$output"
        exit 0
      fi

      echo "Tailscale connectivity check failed ($attempt/8): $output"

      hundredths=$((delay * (95 + RANDOM % 11)))
      printf -v sleep_for '%d.%02d' "$((hundredths / 100))" "$((hundredths % 100))"
      sleep "$sleep_for"
      delay=$((delay * 2))
    done

    echo "Tailscale control plane failed 8 consecutive checks; restarting tailscaled"
    systemctl restart tailscaled
  '';
in {
  config = mkIf (cfg.enable && cfg.recovery.enable) {
    systemd = {
      services.tailscale-recovery = {
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
  };
}
