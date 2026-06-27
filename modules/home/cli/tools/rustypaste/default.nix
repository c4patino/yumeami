{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.tools.rustypaste";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "rustypaste";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        rustypaste-cli
      ];

      file = let
        crypt = "${config.snowfallorg.user.home.directory}/dotfiles/secrets/crypt";
      in {
        ".config/rustypaste/config.toml".source =
          "${crypt}/rustypaste/client.toml"
          |> config.lib.file.mkOutOfStoreSymlink;
      };
    };
  };
}
