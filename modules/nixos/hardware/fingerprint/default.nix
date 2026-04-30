{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.hardware.fingerprint";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "fingerprint signins";
  };

  config = mkIf cfg.enable {
    services.fprintd = {
      enable = true;
    };

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/fprint"];
  };
}
