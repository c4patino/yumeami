{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkOpt mkRequiredOpt mkNullableOpt mkListOpt mkOptAttrset;
  inherit (config.sops) secrets;
  inherit (config.networking) hostName;
  base = "${namespace}.services.ci.gitea-runner";
  cfg = getAttrByNamespace config base;
  nvdaCfg = getAttrByNamespace config "${namespace}.hardware.nvidia";
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Gitea self-hosted runnner";
      runners = mkOptAttrset (submodule {
        options = {
          capacity = mkOpt int 1 "Maximum number of concurrent jobs for this runner.";
          tokenFile = mkNullableOpt path null "Path to the token file to utilize for authentication";
          url = mkOpt str "https://git.cpatino.com" "URL of the repository for which to add the self-hosted runner.";
          labels = mkListOpt str [
            "nixos-latest:docker://nixos/nix:latest"
            "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:full-latest"
            "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:full-24.04"
            "ubuntu-22.04:docker://ghcr.io/catthehacker/ubuntu:full-22.04"
          ] "Set of labels to apply to the runner instance.";
        };
      }) {} "Definition of runners to enable to the device";
    };

  config = mkIf cfg.enable {
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;

      instances = let
        inherit (lib) mapAttrsToList listToAttrs optional;

        mkRunnerConfig = name: runner: {
          name = name;
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

            settings = {
              log.level = "info";

              cache = {
                enabled = true;
                dir = "/var/cache/forgejo-runner/actions";
                host = "172.17.0.1";
                proxy_port = 37323;
              };

              runner = {
                capacity = runner.capacity;
                envs = {
                  "USER" = "runner";
                };
              };

              container = {
                network = "bridge";
                privileged = false;
                docker_host = "automount";
              };
            };
          };
        };
      in
        cfg.runners
        |> mapAttrsToList mkRunnerConfig
        |> listToAttrs;
    };

    sops.secrets = {
      "forgejo/gpg/forgejo-actions-bot/private" = {};
      "forgejo/gpg/forgejo-actions-bot/public" = {};
      "forgejo/token" = {};
    };

    networking.firewall.allowedTCPPorts = [37323];
  };
}
