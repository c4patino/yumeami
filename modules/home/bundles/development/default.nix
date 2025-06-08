{
  config,
  lib,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.bundles.development";
  cfg = getAttrByNamespace config base;
in {
  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "development bundle";
    };

  config = mkIf cfg.enable {
    ${namespace} = {
      cli = {
        dev = {
          direnv = enabled;
          git = enabled;
          lazygit = enabled;
          neovim = enabled;
          zoxide = enabled;
        };
      };
    };
  };
}
