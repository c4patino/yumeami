{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) enabled getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.bundles.development";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "development bundle";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      devenv
      forgejo-cli
      mprocs
      terraform
      tokei
    ];

    ${namespace} = {
      cli.dev = {
        direnv = enabled;
        gh = enabled;
        git = enabled;
        harlequin = enabled;
        lazygit = enabled;
        neovim = enabled;
        opencode = enabled;
        openspec = enabled;
        tuicr = enabled;
      };
    };

    sops.secrets = let
      inherit (config.snowfallorg) user;
    in {
      "github/auth" = {
        path = "${user.home.directory}/.local/state/nh/github-token";
      };
    };
  };
}
