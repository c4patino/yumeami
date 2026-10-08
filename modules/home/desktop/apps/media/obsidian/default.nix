{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf types;
  inherit (lib.${namespace}) getAttrByNamespace mkBoolOpt mkOpt mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.media.obsidian";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Obsidian";

    sync = {
      enable = mkBoolOpt true "Whether to auto-commit and push vault edits from a user service.";
      vaults = mkOpt (types.listOf types.str) [
        "${config.home.homeDirectory}/Documents/obsidian"
      ] "Vault directories to keep synchronized with origin.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];

    systemd.user = mkIf cfg.sync.enable {
      services.obsidian-vault-sync = {
        Unit.Description = "Auto-commit and push Obsidian vault edits";

        Service = let
          sync = import ./vault-sync.nix {
            inherit lib pkgs;
            inherit (cfg.sync) vaults;
          };
        in {
          Type = "oneshot";
          ExecStart = "${sync}/bin/obsidian-vault-sync";
        };
      };

      timers.obsidian-vault-sync = {
        Unit.Description = "Timer for Obsidian vault sync";

        Timer.OnUnitActiveSec = "1m";

        Install.WantedBy = ["timers.target"];
      };
    };
  };
}
