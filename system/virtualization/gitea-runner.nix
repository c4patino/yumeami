{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption mapAttrs attrValues concatLists listToAttrs genList;
  inherit (config.sops) secrets;
  inherit (config.networking) hostName;
  cfg = config.gitea-runners;
  nvdaCfg = config.nvidia;
in {
  options.gitea-runners = with types; {
    enable = mkEnableOption "Gitea self-hosted runners";
    runners = mkOption {
      description = "Definition of runners to enable to the device";
      type = attrsOf (submodule {
        options = {
          instances = mkOption {
            type = int;
            default = 1;
            description = "Number of instances of the runner to spawn for this configuration.";
          };
          tokenFile = mkOption {
            type = nullOr path;
            default = null;
            description = "Path to the token file to utilize for authentication";
          };
          url = mkOption {
            type = str;
            default = "https://git.yumeami.sh";
            description = "URL of the repository for which to add the self-hosted runner.";
          };
          labels = mkOption {
            type = listOf str;
            default = [
              "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
              "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
              "ubuntu-20.04:docker://ghcr.io/catthehacker/ubuntu:act-20.04"
            ];
            description = "Set of labels to apply to the runner instance.";
          };
        };
      });
      default = {};
    };
  };

  config = mkIf cfg.enable {
    services.gitea-actions-runner = {
      package = pkgs.forgejo-actions-runner;

      instances = let
        mkRunnerConfig = {
          index,
          name,
          runner,
        }: {
          name = "${name}-${toString index}";
          value = {
            enable = true;
            name =
              if name == "default"
              then hostName
              else "${hostName}-${name}";
            tokenFile =
              if runner.tokenFile == null
              then secrets."forgejo".path
              else runner.tokenFile;
            url = runner.url;
            labels = runner.labels ++ lib.optional nvdaCfg.enable "gpu";
          };
        };
      in
        cfg.runners
        |> mapAttrs (name: runner:
          genList (idx: {
            index = idx;
            name = name;
            runner = runner;
          })
          runner.instances)
        |> attrValues
        |> concatLists
        |> map mkRunnerConfig
        |> listToAttrs;
    };
  };
}
