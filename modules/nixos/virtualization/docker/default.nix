{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOverride;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.virtualization.docker";
  cfg = getAttrByNamespace config base;
  nvdaCfg = getAttrByNamespace config "${namespace}.hardware.nvidia";
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "docker";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [libnvidia-container nvidia-container-toolkit];

    hardware.nvidia-container-toolkit.enable = nvdaCfg.enable;

    virtualisation = {
      containers = {
        enable = true;
        containersConf.settings.containers.label = false;
      };

      docker = {
        enable = true;
        rootless = {
          enable = true;
          setSocketVariable = true;
        };
        daemon.settings = {
          hosts = ["unix:///var/run/docker.sock" "tcp://0.0.0.0:2376"];
          runtimes = {
            nvidia = {
              args = [];
              path = "nvidia-container-runtime";
            };
          };
        };
      };

      oci-containers.backend = mkOverride 0 "docker";
    };

    networking.firewall.allowedTCPPorts = [2376];

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/docker"];
  };
}
