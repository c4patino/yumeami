{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  system,
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

      inputs.openspec.packages.${system}.default
    ];

    ${namespace} = {
      cli.dev = {
        direnv = enabled;
        git = enabled;
        harlequin = enabled;
        lazygit = enabled;
        neovim = enabled;
        opencode = enabled;
      };
    };
  };
}
