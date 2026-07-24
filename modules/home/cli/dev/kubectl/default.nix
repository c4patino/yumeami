{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.kubectl";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "kubectl";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        kubectl
        tanzu-cli
      ];

      file.".kube/config" = {
        source =
          "${config.snowfallorg.user.home.directory}/dotfiles/secrets/crypt/kubectl.yaml"
          |> config.lib.file.mkOutOfStoreSymlink;
      };
    };
  };
}
