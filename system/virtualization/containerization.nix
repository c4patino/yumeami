{
  pkgs,
  lib,
  config,
  ...
}: {
  options.containerization.enable = lib.mkEnableOption "Podman, Docker, and Distrobox support";

  config = lib.mkIf config.containerization.enable {
    hardware.nvidia-container-toolkit.enable = config.nvidia.enable;

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
