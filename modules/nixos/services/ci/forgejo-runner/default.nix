{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) listToAttrs mapAttrs' mapAttrsToList mkEnableOption mkForce mkIf mkMerge types;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService mkListOpt mkOpt mkOptAttrset mkOptionsWithNamespace waitForNetwork;
  inherit (config.sops) secrets;
  inherit (config.networking) hostName;
  base = "${namespace}.services.ci.forgejo-runner";
  cfg = getAttrByNamespace config base;
  nvdaCfg = getAttrByNamespace config "${namespace}.hardware.nvidia";
  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Forgejo self-hosted runner";
      capacity = mkOpt int 1 "Maximum number of concurrent jobs for the runner instance.";
      connections = mkOptAttrset (submodule {
        options = {
          name = mkOpt str "default" "Name of the connection (used in forgejo web UI).";
          url = mkOpt str "https://git.cpatino.com" "URL of the Forgejo instance.";
          labels = mkListOpt str [
            "nixos-latest:docker://nixos/nix:latest"
            "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:full-latest"
            "ubuntu-24.04:docker://ghcr.io/catthehacker/ubuntu:full-24.04"
            "ubuntu-slim:docker://ghcr.io/catthehacker/ubuntu:slim"
          ] "Set of labels to apply to the runner for this connection.";
        };
      }) {} "Definition of connections to enable to the device";
    };

  config = mkIf cfg.enable {
    services.forgejo-runner = {
      instances.default = {
        enable = true;
        settings = {
          server = {
            connections = let
              mkConnection = name: conn: {
                enable = true;
                settings = {
                  url = conn.url;
                  uuid = secrets."forgejo/runner/${name}/uuid".path;
                  runner.labels = let
                    gpuLabels =
                      if nvdaCfg.enable
                      then ["gpu"]
                      else [];
                  in
                    conn.labels ++ gpuLabels;
                };

                secrets = {
                  token_url = secrets."forgejo/runner/${name}/token".path;
                };
              };
            in
              cfg.connections
              |> mapAttrsToList mkConnection
              |> listToAttrs;
          };
        };

        capacity = cfg.capacity;

        runtimes.docker = {
          enable = true;
          privileged = false;
          docker_host = "automount";
          network = "bridge";
          options = "--device=/dev/net/tun:/dev/net/tun --cap-add=NET_ADMIN";
        };
      };
    };

    # Define secrets for all connections
    sops.secrets = let
      mkConnectionSecrets = name: conn: {
        "forgejo/runner/${name}/token" = {};
        "forgejo/runner/${name}/uuid" = {};
      };
    in
      cfg.connections
      |> mapAttrsToList mkConnectionSecrets
      |> listToAttrs
      |> lib.mkMerge;

    networking.firewall.allowedTCPPorts = [37323];

    systemd.services = let
      mkConnectionService = name: conn: {
        name = "forgejo-runner-${name}";
        value = mkMerge [
          {
            environment = {
              DOCKER_HOST = mkForce "unix:///var/run/docker.sock";
            };
            serviceConfig = {
              SupplementaryGroups = ["docker" "podman"];
            };
          }
          (mkIf (hostHasService networkCfg.registry hostName "git") {
            requires = ["forgejo.service"];
            after = ["forgejo.service"];
          })
          waitForNetwork
        ];
      };
    in
      cfg.connections
      |> mapAttrs' mkConnectionService;
  };
}
