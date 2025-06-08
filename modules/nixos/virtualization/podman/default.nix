{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.virtualization.podman";
  cfg = getAttrByNamespace config base;
  nvdaBase = "${namespace}.hardware.nvidia";
  nvdaCfg = getAttrByNamespace config nvdaBase;
in {
  options = with types;
    mkOptionsWithNamespace base {
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

      oci-containers.backend = mkOverride 10 "podman";
    };

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/containers"];
  };
}
