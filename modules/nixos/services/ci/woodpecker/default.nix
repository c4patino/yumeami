{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption mkEnableOption types mapAttrs' mkMerge filterAttrs listToAttrs;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP;
  base = "${namespace}.services.ci.woodpecker";
  cfg = getAttrByNamespace config base;
  networkingCfg = getAttrByNamespace config "${namespace}.services.networking";

  port = 5301;
  gprcPort = 5302;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "woodpecker";
      runners = mkOption {
        description = "Definition of runners to enable to the device";
        type = attrsOf (submodule {
          options = {
            enable = mkEnableOption "woodpecker runner";
            capacity = mkOption {
              type = int;
              default = 1;
              description = "Number of concurrent workflows this runner can execute.";
            };
            token = mkOption {
              type = nullOr path;
              default = null;
              description = "Path to the agent secret token file for authentication. If null, the default secret will be used.";
            };
          };
        });
        default = {};
      };
    };

  config = {
    services = let
      inherit (config.sops) secrets;
    in {
      woodpecker-server = mkIf cfg.enable {
        enable = true;
        environment = {
          WOODPECKER_HOST = "https://woodpecker.yumeami.sh";
          WOODPECKER_SERVER_ADDR = ":${toString port}";
          WOODPECKER_GRPC_ADDR = ":${toString gprcPort}";

          WOODPECKER_OPEN = "false";
          WOODPECKER_ADMIN = "c4patino";

          WOODPECKER_AGENT_SECRET_FILE = secrets."woodpecker/agents/secret".path;

          WOODPECKER_FORGEJO = "true";
          WOODPECKER_FORGEJO_URL = "https://git.cpatino.com";
          WOODPECKER_FORGEJO_CLIENT_FILE = secrets."woodpecker/forgejo/client".path;
          WOODPECKER_FORGEJO_SECRET_FILE = secrets."woodpecker/forgejo/secret".path;
        };
      };

      woodpecker-agents.agents = let
        mkRunnerCfg = name: r: {
          inherit name;

          value = {
            enable = r.enable;

            environment = {
              WOODPECKER_SERVER = let
                woodpeckerIP =
                  networkingCfg.network-services.woodpecker.host
                  |> resolveHostIP networkingCfg.devices;
              in "${woodpeckerIP}:${toString gprcPort}";
              WOODPECKER_AGENT_SECRET_FILE =
                if r.token != null
                then r.token
                else secrets."woodpecker/agents/secret".path;

              WOODPECKER_MAX_WORKFLOWS = toString r.capacity;

              WOODPECKER_BACKEND = "docker";
              DOCKER_HOST = "unix:///run/podman/podman.sock";
            };

            extraGroups = ["podman"];

            path = with pkgs; [
              git
              git-lfs
              woodpecker-plugin-git
              bash
              coreutils
            ];
          };
        };
      in
        cfg.runners |> mapAttrs' mkRunnerCfg;
    };

    users = {
      users.woodpecker = {
        isSystemUser = true;
        group = "woodpecker";
      };
      groups.woodpecker = {};
    };

    sops.secrets = let
      mkSecret = s: {
        name = s;
        value = {
          owner = config.users.users.woodpecker.name;
          group = config.users.users.woodpecker.group;
        };
      };
    in
      [
        "woodpecker/forgejo/client"
        "woodpecker/forgejo/secret"
        "woodpecker/github/client"
        "woodpecker/github/secret"
        "woodpecker/agents/secret"
      ]
      |> map mkSecret
      |> listToAttrs;

    systemd.services = let
      User = config.users.users.woodpecker.name;
      Group = config.users.users.woodpecker.group;
      inherit (config.networking) hostName;
      woodpeckerHost = networkingCfg.network-services.woodpecker.host;
    in
      mkMerge [
        (mkIf cfg.enable {
          woodpecker-server = {
            serviceConfig = {inherit User Group;};
          };
        })
        (
          cfg.runners
          |> filterAttrs (_: r: r.enable)
          |> mapAttrs' (name: r: {
            name = "woodpecker-agent-${name}";
            value = {
              after = mkIf (hostName == woodpeckerHost) ["woodpecker-server.service"];
              requires = mkIf (hostName == woodpeckerHost) ["woodpecker-server.service"];
              serviceConfig = {inherit User Group;};
            };
          })
        )
      ];
  };
}
