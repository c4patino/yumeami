{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService resolveServicePort waitForNetwork;

  nvidiaCfg = getAttrByNamespace config "${namespace}.hardware.nvidia";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";

  isEnabled = hostHasService networkCfg.network-services (config.networking.hostName) "ollama";
  port = resolveServicePort networkCfg.network-services "ollama" 11434;
in {
  config = mkIf isEnabled {
    services.ollama = {
      inherit port;

      enable = true;

      package =
        if nvidiaCfg.enable
        then pkgs.ollama-cuda
        else pkgs.ollama;

      syncModels = true;
      loadModels = [
        "qwen3-coder-next:q4_K_M"
        "qwen3.5:9b"
      ];

      environmentVariables = {
        CUDA_VISIBLE_DEVICES = "0";

        OLLAMA_CONTEXT_LENGTH = "65356";
        OLLAMA_KEEP_ALIVE = "20m";
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_NUM_THREADS = "12";
      };
    };

    systemd.services.ollama = mkMerge [
      waitForNetwork
      {
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "1s";
        };
      }
    ];
  };
}
