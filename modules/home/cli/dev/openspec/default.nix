{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  system,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.openspec";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "OpenSpec";
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        inputs.openspec.packages.${system}.default
      ];

      file.".config/openspec/config.json" = {
        source = inputs.dotfiles + "/.config/openspec/config.json";
      };
    };

    systemd.user = {
      services.openspec-repo-sync = {
        Unit.Description = "Automatically synchronize OpenSpec repositories";

        Service = let
          repoSync = import ./repo-sync.nix {
            inherit config lib pkgs;
          };
        in {
          Type = "oneshot";
          ExecStart = "${repoSync}/bin/openspec-repo-sync";
        };
      };

      timers.openspec-repo-sync = {
        Unit.Description = "Automatically synchronize OpenSpec repositories";

        Timer = {
          OnBootSec = "5m";
          OnUnitActiveSec = "1m";
        };

        Install.WantedBy = ["timers.target"];
      };
    };
  };
}
