{
  config,
  host,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkAfter mkEnableOption mkIf mkOption types;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.azure";
  cfg = getAttrByNamespace config base;

  inherit (cfg) org;
  patFile = config.sops.secrets."azure-devops/auth".path;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "azure devops";

    org = mkOption {
      type = types.str;
      description = "Azure DevOps organization name (the <org> in dev.azure.com/<org>).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (azure-cli.withExtensions [azure-cli.extensions.azure-devops])
    ];

    programs = {
      git.settings = {
        credential."https://dev.azure.com" = {
          useHttpPath = true;

          helper = "${pkgs.writeShellScript "git-credential-azure-devops" ''
            [ "$1" = "get" ] || exit 0
            echo "username=pat"
            echo "password=$(< ${patFile})"
          ''}";
        };

        url."https://dev.azure.com/${org}/".insteadOf = "https://${org}@dev.azure.com/${org}/";
      };

      bash.initExtra = mkAfter ''
        export AZURE_DEVOPS_EXT_PAT="$(< ${patFile})"
      '';

      nushell.extraConfig = mkAfter ''
        $env.AZURE_DEVOPS_EXT_PAT = (open --raw ${patFile} | str trim)
      '';

      zsh.initContent = mkAfter ''
        export AZURE_DEVOPS_EXT_PAT="$(< ${patFile})"
      '';
    };

    sops.secrets."azure-devops/auth" = {
      sopsFile = "${inputs.self}/secrets/sops/${host}.yaml";
    };
  };
}
