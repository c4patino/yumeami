{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.desktop.apps.teamviewer";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Teamviewer";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [teamviewer];

    services.teamviewer = enabled;

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/teamviewer"];
  };
}
