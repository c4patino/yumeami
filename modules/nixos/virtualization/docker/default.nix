{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOverride;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.virtualization.docker";
  cfg = getAttrByNamespace config base;
  nvdaBase = "${namespace}.hardware.nvidia";
  nvdaCfg = getAttrByNamespace config nvdaBase;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "docker";
  };

  config = mkIf cfg.enable {
    hardware.nvidia-container-toolkit.enable = nvdaCfg.enable;

    virtualisation = {
      containers = {
        enable = true;
        containersConf.settings.containers.label = false;
      };

      docker = {
        enable = true;
        daemon.settings = {
          hosts = ["unix:///var/run/docker.sock" "tcp://0.0.0.0:2376"];
        };
      };

      oci-containers.backend = mkOverride 0 "docker";
    };

    networking.firewall.allowedTCPPorts = [2376];

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/docker"];
  };
}
