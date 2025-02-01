{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    github-runners.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Github Action Runner";
    };
    github-runners.runners = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [
        {
          name = "${config.networking.hostName}-nixos-config";
          tokenFile = config.sops.secrets."github/runner".path;
          url = "https://github.com/c4patino/nixos-config";
        }
        {
          name = "${config.networking.hostName}-nixvim";
          tokenFile = config.sops.secrets."github/runner".path;
          url = "https://github.com/c4patino/nixvim";
        }
        {
          name = "${config.networking.hostName}-neovim";
          tokenFile = config.sops.secrets."github/runner".path;
          url = "https://github.com/c4patino/neovim";
        }
        {
          name = "${config.networking.hostName}-dotfiles";
          tokenFile = config.sops.secrets."github/runner".path;
          url = "https://github.com/c4patino/dotfiles";
        }
        {
          name = "${config.networking.hostName}-days-since";
          tokenFile = config.sops.secrets."github/runner".path;
          url = "https://github.com/c4patino/days-since";
        }
        {
          name = "${config.networking.hostName}-free-range-rust";
          tokenFile = config.sops.secrets."github/runner".path;
          url = "https://github.com/c4patino/free-range-rust";
        }
        {
          name = "${config.networking.hostName}-free-range-zoo";
          tokenFile = config.sops.secrets."github/runner-oasys".path;
          url = "https://github.com/oasys-mas";
        }
      ];
      description = "List of GitHub runners to configure";
    };
  };

  config = lib.mkIf config.github-runners.enable {
    services.github-runners = lib.foldl' (acc: runner:
      acc
      // {
        "${runner.name}" = {
          enable = true;
          name = config.networking.hostName;
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
