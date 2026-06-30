{
  config,
  inputs,
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

      file = {
        ".config/rustypaste/config.toml" = {
          source = inputs.dotfiles + "/.config/rustypaste/config.toml";
        };
      };
    };

    sops.secrets = let
      inherit (config.snowfallorg) user;
    in {
      "rustypaste/auth".path = "${user.home.directory}/.config/rustypaste/auth_token";
      "rustypaste/delete".path = "${user.home.directory}/.config/rustypaste/delete_token";
    };
  };
}
