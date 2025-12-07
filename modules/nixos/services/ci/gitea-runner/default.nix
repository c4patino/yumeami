{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption;
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
                "nixos-latest:docker://nixos/nix:latest"
                "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:full-latest"
                "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:full-24.04"
                "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:full-22.04"
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
      package = pkgs.forgejo-runner;

      instances = let
        inherit (lib) concatLists genList listToAttrs mapAttrsToList optional replicate imap0;
        inherit (builtins) stringLength concatStringsSep;

        padIndex = idx: concatStringsSep "" (replicate (3 - stringLength (toString idx)) "0") + toString idx;

        mkRunnerConfig = inst: {
          name = "${inst.name}-${padIndex inst.perGroupIndex}";
          value = {
            enable = true;
            name =
              if inst.name == "default"
              then hostName
              else "${hostName}-${inst.name}";
            tokenFile =
              if inst.runner.tokenFile == null
              then secrets."forgejo/token".path
              else inst.runner.tokenFile;
            url = inst.runner.url;
            labels = inst.runner.labels ++ optional nvdaCfg.enable "gpu";

            settings.cache = {
              enabled = true;
              dir = "";
              host = "";
              port = 0;
            };
          };
        };
      in
        cfg.runners
        |> mapAttrsToList (name: runner:
          genList (idx: {
            name = name;
            runner = runner;
            perGroupIndex = idx;
          })
          runner.instances)
        |> concatLists
        |> imap0 (globalIndex: inst: inst // {inherit globalIndex;})
        |> map mkRunnerConfig
        |> listToAttrs;
    };

    sops.secrets = {
      "forgejo/gpg/private" = {};
      "forgejo/gpg/public" = {};
      "forgejo/token" = {};
    };

    networking.firewall.trustedInterfaces = ["docker0" "podman1"];
  };
}
