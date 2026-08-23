{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOverride;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkPersistRootDir;
  base = "${namespace}.virtualization.docker";
  cfg = getAttrByNamespace config base;
  nvdaCfg = getAttrByNamespace config "${namespace}.hardware.nvidia";
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "docker";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libnvidia-container
      nvidia-container-toolkit
    ];

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

    programs.nix-ld.libraries = with pkgs; [
      libsecret
      glib
    ];

    networking.firewall.extraCommands = ''
      iptables -I nixos-fw 1 -p tcp --dport 2376 -s 100.64.0.0/10 -j nixos-fw-accept
      ip6tables -I nixos-fw 1 -p tcp --dport 2376 -s fd7a:115c:a1e0::/48 -j nixos-fw-accept
    '';

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/var/lib/docker" "700")
    ];
  };
}
