{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.ollama";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "ollama";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;

      syncModels = true;
      loadModels = [
        "qwen3-coder-next:q4_K_M"
        "qwen3.5:9b"
      ];

      environmentVariables = {
        CUDA_VISIBLE_DEVICES = "0";

        OLLAMA_CONTEXT_LENGTH = "32678";
        OLLAMA_KEEP_ALIVE = "20m";
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_NUM_THREADS = "12";
      };
    };
  };
}
