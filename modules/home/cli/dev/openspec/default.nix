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

  timerInterval = "5m";
  openSpecRepoAutoSync = import ./auto-sync-script.nix {
    inherit lib pkgs;
    dataDir = "${config.xdg.stateHome}/openspec-repo-auto-sync";
    idleThreshold = 20 * 60;
    openspecRoot = "${config.home.homeDirectory}/openspec";
    pullInterval = 5 * 60;
  };
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "OpenSpec";
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.openspec.packages.${system}.default
    ];

    systemd.user = {
      services.openspec-repo-auto-sync = {
        Unit.Description = "Automatically synchronize OpenSpec repositories";

        Service = {
          Type = "oneshot";
          ExecStart = "${openSpecRepoAutoSync}";
        };
      };

      timers.openspec-repo-auto-sync = {
        Unit.Description = "Automatically synchronize OpenSpec repositories";

        Timer = {
          OnBootSec = timerInterval;
          OnUnitActiveSec = timerInterval;
          Unit = "openspec-repo-auto-sync.service";
          Persistent = true;
        };

        Install.WantedBy = ["timers.target"];
      };
    };
  };
}
