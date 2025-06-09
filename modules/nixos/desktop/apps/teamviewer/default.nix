{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.desktop.apps.teamviewer";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Teamviewer";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [teamviewer];

    services.teamviewer = enabled;

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/teamviewer"];
  };
}
