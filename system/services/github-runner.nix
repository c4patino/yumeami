{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) types mapAttrs';
  inherit (config.networking) hostName;
  inherit (config.sops) secrets;
in {
  options.github-runners = {
    enable = lib.mkEnableOption "Github self-hosted runners";
    runners = lib.mkOption {
      description = "Definition of runners to enable to the device";
      type = types.attrsOf (types.submodule {
        options = {
          tokenFile = lib.mkOption {
            type = types.nullOr types.path;
            default = null;
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
    services.github-runners =
      mapAttrs' (name: runner: {
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
          extraLabels = lib.mkIf config.nvidia.enable ["gpu"];
          user = "root";
          group = "root";
        };
      })
      config.github-runners.runners;
  };
}
