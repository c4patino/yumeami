{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkPersistRootDir;
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

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/fprint")
    ];
  };
}
