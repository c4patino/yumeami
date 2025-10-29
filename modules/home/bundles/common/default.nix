{
  config,
  host,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption listToAttrs flatten;
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

    sops.secrets = let
      inherit (config.snowfallorg) user;
      keyObj = extraAttrs: key: [
        {
          name = "gpg/${key}/private";
          value =
            {
              path = "${user.home.directory}/.gnupg/${key}.private.asc";
              mode = "0700";
            }
            // extraAttrs;
        }
        {
          name = "gpg/${key}/public";
          value =
            {
              path = "${user.home.directory}/.gnupg/${key}.public.asc";
              mode = "0700";
            }
            // extraAttrs;
        }
      ];

      emails =
        ["c4patino@gmail.com" "cpatino2@nebraska.edu" "cpatino8605@gmail.com"]
        |> map (keyObj {})
        |> flatten;

      users =
        ["c4patino"]
        |> map (keyObj {sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";})
        |> flatten;
    in
      (users ++ emails)
      |> listToAttrs;

    programs.bash.initExtra = ''
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
  };
}
