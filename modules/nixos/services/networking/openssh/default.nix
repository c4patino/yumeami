{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.networking.openssh";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "openssh";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;

      settings.StrictModes = false;

      hostKeys = let
        inherit (config.sops) secrets;
      in [
        {
          bits = 4096;
          path = secrets."ssh/server/private_rsa".path;
          type = "rsa";
        }
        {
          path = secrets."ssh/server/private_ed25519".path;
          type = "ed25519";
        }
      ];
    };
  };
}
