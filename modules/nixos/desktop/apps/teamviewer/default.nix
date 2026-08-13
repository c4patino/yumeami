{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) enabled getAttrByNamespace mkOptionsWithNamespace mkPersistRootDir;
  base = "${namespace}.desktop.apps.teamviewer";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Teamviewer";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [teamviewer];

    services.teamviewer = enabled;

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/teamviewer" "700")
    ];
  };
}
