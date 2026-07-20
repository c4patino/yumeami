{
  config,
  inputs,
  lib,
  namespace,
  system,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.jiratui";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "jiratui";
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        inputs.jiratui.packages.${system}.default
      ];

      file.".config/jiratui/config.yaml" = {
        source =
          "${config.snowfallorg.user.home.directory}/dotfiles/secrets/crypt/jiratui.yaml"
          |> config.lib.file.mkOutOfStoreSymlink;
      };
    };
  };
}
