{
  config,
  lib,
  namespace,
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
    ${namespace} = {
      cli.dev = {
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
