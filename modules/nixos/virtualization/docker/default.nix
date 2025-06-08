{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.virtualization.docker";
  cfg = getAttrByNamespace config base;
  nvdaBase = "${namespace}.hardware.nvidia";
  nvdaCfg = getAttrByNamespace config nvdaBase;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "docker";
    };

  config = mkIf cfg.enable {
    hardware.nvidia-container-toolkit.enable = nvdaCfg.enable;

    virtualisation = {
      containers = {
        enable = true;
        containersConf.settings.containers.label = false;
      };

      oci-containers.backend = mkOverride 0 "docker";
    };

    networking.firewall.allowedTCPPorts = [2376];

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/docker"];
  };
}
