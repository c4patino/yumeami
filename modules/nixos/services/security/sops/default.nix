{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption listToAttrs;
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
    sops = let
      inherit (config.networking) hostName;
      sopsFolder = "${inputs.self}/secrets/sops";
    in {
      defaultSopsFile = "${inputs.self}/secrets/sops/secrets.yaml";
      defaultSopsFormat = "yaml";

      secrets = let
        root =
          [
            "ssh/server/private_ed25519"
            "ssh/server/private_rsa"
            "ssh/server/public_ed25519"
            "ssh/server/public_rsa"
            "ssl/syncthing/cert"
            "ssl/syncthing/key"
          ]
          |> map (name: {
            inherit name;
            value = {
              sopsFile = "${sopsFolder}/${hostName}.yaml";
            };
          });
        wwwrun =
          [
            "ssl/wildcard_cpatino_com/cert"
            "ssl/wildcard_cpatino_com/key"
            "ssl/wildcard_yumeami_sh/cert"
            "ssl/wildcard_yumeami_sh/key"
          ]
          |> map (name: {
            inherit name;
            value = {
              sopsFile = "${sopsFolder}/${hostName}.yaml";
              owner = config.users.users.wwwrun.name;
              group = config.users.users.wwwrun.group;
            };
          });
      in
        (root ++ wwwrun)
        |> listToAttrs;
    };
  };
}
