{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.tools.asciinema";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "asciinema";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        asciinema
      ];

      file = let
        crypt = "${config.snowfallorg.user.home.directory}/dotfiles/secrets/crypt";
      in {
        ".config/asciinema/config.toml".source =
          "${crypt}/asciinema/config.toml"
          |> config.lib.file.mkOutOfStoreSymlink;
      };
    };
  };
}
