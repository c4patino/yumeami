{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.services.networking.tailscale";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Tailscale";
    };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/tailscale"];
  };
}
