{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption mapAttrs' optional;
  inherit (config.networking) hostName;
  inherit (config.sops) secrets;
  cfg = config.github-runners;
  nvdaCfg = config.nvidia;
in {
  options.github-runners = with types; {
    enable = mkEnableOption "Github self-hosted runners";
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
      generateRunnerConfiguration = name: runner: {
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
          extraPackages = with pkgs; [openssl docker];
          extraLabels = ["nix"] ++ optional nvdaCfg.enable "gpu";
          user = "root";
          group = "root";
        };
      };
    in
      cfg.runners |> mapAttrs' generateRunnerConfiguration;
  };
}
