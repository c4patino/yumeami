{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption genList mapAttrs optional attrValues concatLists listToAttrs;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  inherit (config.sops) secrets;
  inherit (config.networking) hostName;
  base = "${namespace}.services.ci.gitea-runner";
  cfg = getAttrByNamespace config base;
  nvdaCfg = getAttrByNamespace config "${namespace}.hardware.nvidia";
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Gitea self-hosted runnner";
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
              default = "https://git.cpatino.com";
              description = "URL of the repository for which to add the self-hosted runner.";
            };
            labels = mkOption {
              type = listOf str;
              default = [
                "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
                "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:act-24.04"
                "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:act-22.04"
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
              then secrets."forgejo/token".path
              else runner.tokenFile;
            url = runner.url;
            labels = runner.labels ++ optional nvdaCfg.enable "gpu";
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

    sops.secrets = {
      "forgejo/gpg/private" = {};
      "forgejo/gpg/public" = {};
      "forgejo/token" = {};
    };
  };
}
