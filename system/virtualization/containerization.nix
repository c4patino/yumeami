{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    containerization.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable containerization support";
    };
  };

  config = lib.mkIf config.containerization.enable {
    hardware.nvidia-container-toolkit.enable = config.nvidia.enable;

    environment.systemPackages = with pkgs; [
      distrobox
      podman-compose
    ];

    virtualisation = {
      containers.enable = true;
      podman.enable = true;
      docker.enable = true;

      oci-containers.backend = "podman";
    };
  };
}
