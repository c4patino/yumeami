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
  base = "${namespace}.services.security.ca";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "ca certificates";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [openssl];

    security.pki.certificateFiles = [
      "${inputs.self}/secrets/crypt/ssl/ca.crt"
    ];
  };
}
