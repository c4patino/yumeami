{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption mapAttrs' optional;
  inherit (config.networking) hostName;
  cfg = config.github-runners;
  nvdaCfg = config.nvidia;
in {
  options.gitea-runners = with types; {
    enable = mkEnableOption "Gitea self-hosted runners";
    runners = mkOption {
      description = "Definition of runners to enable to the device";
      type = attrsOf (submodule {
        options = {
          tokenFile = mkOption {
            type = path;
            description = "Path to the token file to utilize for authentication";
          };
          url = mkOption {
            type = str;
            description = "URL of the repository for which to add the self-hosted runner";
          };
        };
      });
      default = [];
    };
  };

  config = mkIf cfg.enable {
    services.gitea-actions-runner = {
      package = pkgs.forgejo-actions-runner;

      instances = let
        mkRunnerConfig = name: runner: {
          name = hostName;
          value = {
            enable = true;
            tokenFile = runner.tokenFile;
            url = "https://forgejo.yumeami.sh";
          };
        };
      in {};
    };

    # = let
    #   generateRunnerConfiguration = name: runner: {
    #     name = "${hostName}-${name}";
    #     value = {
    #       enable = true;
    #       name = hostName;
    #       replace = true;
    #       ephemeral = true;
    #       tokenFile =
    #         if runner.tokenFile == null
    #         then secrets."github/runner".path
    #         else runner.tokenFile;
    #       url = runner.url;
    #       extraPackages = with pkgs; [openssl docker];
    #       extraLabels = ["nix"] ++ optional nvdaCfg.enable "gpu";
    #       user = "root";
    #       group = "root";
    #     };
    #   };
    # in
    #   cfg.runners |> mapAttrs' generateRunnerConfiguration;

    impermanence.folders = ["/var/lib/github-runner"];
  };
}
