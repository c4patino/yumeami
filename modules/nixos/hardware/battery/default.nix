{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.hardware.battery";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "battery";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [acpi];
  };
}
