{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types;
  inherit (config.networking) hostName;
in {
  options.github-runners = {
    enable = lib.mkEnableOption "Github self-hosted runners";
    runners = lib.mkOption {
      description = "Definition of runners to enable to the device";
      type = types.listOf (types.submodule {
        options = {
          name = lib.mkOption {
            type = types.str;
            default = "";
            description = "Name postfix of the github runners service to guarantee uniqueness";
          };
          tokenFile = lib.mkOption {
            type = types.path;
            default = "";
            description = "Path to the token file to utilize for authentication";
          };
          url = lib.mkOption {
            type = types.str;
            default = "";
            description = "URL of the repository for which to add the self-hosted runner";
          };
        };
      });
      default = [];
    };
  };

  config = lib.mkIf config.github-runners.enable {
    services.github-runners = lib.foldl' (acc: runner:
      acc
      // {
        "${hostName}-${runner.name}" = {
          enable = true;
          name = hostName;
          replace = true;
          ephemeral = true;
          tokenFile = runner.tokenFile;
          url = runner.url;
          extraPackages = with pkgs; [openssl docker];
          extraLabels = lib.mkIf config.nvidia.enable ["gpu"];
          user = "root";
          group = "root";
        };
      }) {}
    config.github-runners.runners;
  };
}
