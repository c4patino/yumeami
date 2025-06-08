{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  base = "${namespace}.cli.access.sops";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "sops-nix";
    };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [sops];
  };
}
