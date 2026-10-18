{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.forgejo";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "forgejo-cli";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        forgejo-cli
      ];

      sessionVariables = {
        FJ_FALLBACK_HOST = "https://git.yumeami.sh";
      };
    };

    sops.secrets."forgejo/auth" = {
      path = "${config.home.homeDirectory}/.local/share/forgejo-cli/keys.json";
    };
  };
}
