{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.bundles.development";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "development bundle";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
      mprocs
      terraform
      tokei
    ];

    ${namespace} = {
      cli.dev = {
        devenv = enabled;
        direnv = enabled;
        git = enabled;
        lazygit = enabled;
        neovim = enabled;
        opencode = enabled;
        zoxide = enabled;
      };
    };
  };
}
