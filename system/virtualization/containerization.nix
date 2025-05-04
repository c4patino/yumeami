{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.containerization;
  nvdaCfg = config.nvidia;
in {
  options.containerization.enable = mkEnableOption "Podman, Docker, and Distrobox support";

  config = mkIf cfg.enable {
    hardware.nvidia-container-toolkit.enable = nvdaCfg.enable;

    environment.systemPackages = with pkgs; [
      distrobox
      podman-compose
    ];

    virtualisation = {
      containers = {
        enable = true;
        containersConf.settings.containers.label = false;
      };

      podman.enable = true;
      docker = {
        enable = true;
        daemon.settings = {
          hosts = ["unix:///var/run/docker.sock" "tcp://0.0.0.0:2376"];
        };
      };

      oci-containers.backend = "podman";
    };

    networking.firewall.allowedTCPPorts = [2376];
  };
}
