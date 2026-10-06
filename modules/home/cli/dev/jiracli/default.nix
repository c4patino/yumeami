{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkAfter mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.jiracli";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "jiracli";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        jira-cli-go
      ];
    };

    programs = {
      bash.initExtra = mkAfter ''
        if [[ -r "$HOME/.config/jira/api_token" ]]; then
          export JIRA_API_TOKEN="$(< "$HOME/.config/jira/api_token")"
        fi
      '';

      nushell.extraConfig = mkAfter ''
        let jira_api_token_file = ($env.HOME | path join ".config" "jira" "api_token")
        if ($jira_api_token_file | path exists) {
          $env.JIRA_API_TOKEN = (open --raw $jira_api_token_file | str trim)
        }
      '';

      zsh.initContent = mkAfter ''
        if [[ -r "$HOME/.config/jira/api_token" ]]; then
          export JIRA_API_TOKEN="$(< "$HOME/.config/jira/api_token")"
        fi
      '';
    };
  };
}
