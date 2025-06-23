{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.virtualization.podman";
  cfg = getAttrByNamespace config base;
  nvdaBase = "${namespace}.hardware.nvidia";
  nvdaCfg = getAttrByNamespace config nvdaBase;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "podman";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [podman-compose];

    hardware.nvidia-container-toolkit.enable = nvdaCfg.enable;

    virtualisation = {
      containers = {
        enable = true;
        containersConf.settings.containers.label = false;
      };

      podman = enabled;
    };

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/containers"];
  };
}
