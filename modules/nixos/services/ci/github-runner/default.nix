{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption mkIf optional mapAttrs';
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  inherit (config.networking) hostName;
  inherit (config.sops) secrets;
  base = "${namespace}.services.ci.github-runner";
  cfg = getAttrByNamespace config base;
  nvdaCfg = getAttrByNamespace config "${namespace}.hardware.nvidia";
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Github self-hosted runner";
      runners = mkOption {
        description = "Definition of runners to enable to the device";
        type = attrsOf (submodule {
          options = {
            tokenFile = mkOption {
              type = nullOr path;
              default = null;
              description = "Path to the token file to utilize for authentication";
            };
            url = mkOption {
              type = str;
              default = "";
              description = "URL of the repository for which to add the self-hosted runner";
            };
          };
        });
        default = [];
      };
    };

  config = mkIf cfg.enable {
    services.github-runners = let
      inherit (config.users.users) github-runner;

      mkRunnerConfig = name: runner: {
        name = "${hostName}-${name}";
        value = {
          enable = true;
          name = hostName;
          replace = true;
          ephemeral = true;
          tokenFile =
            if runner.tokenFile == null
            then secrets."github/runner".path
            else runner.tokenFile;
          url = runner.url;
          extraPackages = with pkgs; let
            gtar = pkgs.runCommandNoCC "gtar" {} ''
              mkdir -p $out/bin
              ln -s ${lib.getExe pkgs.gnutar} $out/bin/gtar
            '';
          in [
            nix
            cachix

            awscli2
            coreutils
            docker
            gh
            gtar
            jq
            nodejs_20
            openssl
            unzip
            which
          ];
          extraLabels = ["nix"] ++ optional nvdaCfg.enable "gpu";
          user = github-runner.name;
          group = github-runner.group;
        };
      };
    in
      cfg.runners |> mapAttrs' mkRunnerConfig;

    users = {
      users.github-runner = {
        isSystemUser = true;
        group = "github-runner";
        extraGroups = ["docker" "podman"];
      };
      groups.github-runner = {};
    };

    ${namespace}.services.storage.impermanence.folders = ["/var/lib/github-runner"];
  };
}
