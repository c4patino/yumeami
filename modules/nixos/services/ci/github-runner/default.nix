{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkOpt mkRequiredOpt mkNullableOpt mkOptAttrset mkPersistDir;
  inherit (config.networking) hostName;
  inherit (config.sops) secrets;
  base = "${namespace}.services.ci.github-runner";
  cfg = getAttrByNamespace config base;
  nvdaCfg = getAttrByNamespace config "${namespace}.hardware.nvidia";
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Github self-hosted runner";
      runners = mkOptAttrset (submodule {
        options = {
          instances = mkOpt int 1 "Number of instances of the runner to spawn for this configuration.";
          tokenFile = mkNullableOpt path null "Path to the token file to utilize for authentication";
          url = mkOpt str "" "URL of the repository for which to add the self-hosted runner";
        };
      }) [] "Definition of runners to enable to the device";
    };

  config = mkIf cfg.enable {
    services.github-runners = let
      inherit (config.users.users) github-runner;
      inherit (lib) attrValues concatLists genList listToAttrs mapAttrs optional replicate;
      inherit (builtins) stringLength concatStringsSep;

      padIndex = idx: concatStringsSep "" (replicate (3 - stringLength (toString idx)) "0") + toString idx;

      mkRunnerConfig = {
        index,
        name,
        runner,
      }: {
        name = "${hostName}-${name}-${padIndex index}";
        value = {
          enable = true;
          name = "${hostName}-${padIndex index}";
          replace = true;
          ephemeral = true;
          tokenFile =
            if runner.tokenFile == null
            then secrets."github/runner".path
            else runner.tokenFile;
          url = runner.url;
          nodeRuntimes = [
            "node24"
          ];
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
            nodejs_24
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

    users = {
      users.github-runner = {
        isSystemUser = true;
        group = "github-runner";
        extraGroups = ["docker" "podman"];
      };
      groups.github-runner = {};
    };

    sops.secrets."github/runner" = {};

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistDir config "github-runner" "/var/lib/github-runner")
    ];
  };
}
