{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.security.sops";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "sops-nix";
  };

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = "${inputs.self}/secrets/sops/secrets.yaml";
      defaultSopsFormat = "yaml";
    };
  };
}
