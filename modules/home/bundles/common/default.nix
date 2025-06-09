{
  config,
  host,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace enabled;
  base = "${namespace}.bundles.common";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "common bundle";
  };

  config = mkIf cfg.enable {
    ${namespace} = {
      cli = {
        access = {
          crypt = enabled;
          sops = enabled;
          ssh = enabled;
        };

        metrics.btm = enabled;
      };
    };

    home = {
      packages = with pkgs; [
        curl
        wget
        zip
        unzip
      ];

      file = let
        crypt = "${inputs.self}/secrets/crypt/";
      in {
        ".ssh/id_ed25519".source = "${crypt}/ssh/${host}/id_ed25519";
        ".ssh/id_ed25519.pub".source = "${crypt}/ssh/${host}/id_ed25519.pub";
        ".config/sops/age/keys.txt".source = "${crypt}/age/${host}/keys.txt";
        ".config/rustypaste/config.toml".source = "${crypt}/rustypaste/client.toml";
      };

      activation.ensureUserDirs = {
        after = ["writeBoundary"];
        before = [];
        data = ''
          mkdir -m 755 -p ~/Downloads
        '';
      };

      sessionVariables = {
        NH_FLAKE = "${config.home.homeDirectory}/dotfiles";
      };
    };
  };
}
