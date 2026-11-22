{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.bundles.homelab";
  cfg = getAttrByNamespace config base;
in {
  imports = [
    ./compute.nix
    ./networking.nix
    ./storage.nix
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "homelab bundle";
  };

  config = mkIf cfg.enable {
    ${namespace}.services.security = {
      ca = enabled;
      gnupg = enabled;
      polkit = enabled;
    };

    sops.secrets = {
      "ssl/ca/cert" = {};
    };
  };
}
