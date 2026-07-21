{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.jiracli";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "jiracli";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        jira-cli-go
      ];

      file.".config/.jira/.config.yml" = {
        source =
          "${config.snowfallorg.user.home.directory}/dotfiles/secrets/crypt/jiracli.yaml"
          |> config.lib.file.mkOutOfStoreSymlink;
      };
    };
  };
}
