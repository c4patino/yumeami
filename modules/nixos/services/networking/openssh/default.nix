{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption listToAttrs;
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

      settings.X11Forwarding = true;

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

    sops.secrets = let
      inherit (config.networking) hostName;
    in
      [
        "ssh/server/private_ed25519"
        "ssh/server/private_rsa"
        "ssh/server/public_ed25519"
        "ssh/server/public_rsa"
      ]
      |> map (name: {
        inherit name;
        value = {
          sopsFile = "${inputs.self}/secrets/sops/${hostName}.yaml";
        };
      })
      |> listToAttrs;
  };
}
