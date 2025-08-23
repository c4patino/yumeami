{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.nushell";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "nushell";
  };

  config = mkIf cfg.enable {
    programs = {
      nushell = {
        enable = true;
        configFile.text = ''
          $env.config = {
              buffer_editor: "nvim"
              edit_mode: "vi"
              show_banner: false
          }

          # gitignore.io command
          def _gitignoreio_list [] {
            http get https://www.toptal.com/developers/gitignore/api/list
            | str replace -a "\n" ","
            | split row ","
            | str trim
            | where {|x| $x != ""}
          }

          def "nu-complete gi" [] { _gitignoreio_list }

          def gi [...args: string@"nu-complete gi"] {
            if ($args | length) > 0 and $args.0 == "list" {
              do { _gitignoreio_list }
            }

            # Join templates with commas and fetch .gitignore
            let joined = ($args | str join ",")
            http get $"https://www.toptal.com/developers/gitignore/api/($joined)"
          }
        '';

        plugins = with pkgs.nushellPlugins; [
          polars
        ];

        shellAliases = {
          shutdown = "sudo shutdown";
          reboot = "sudo reboot";
          rsyncp = "rsync -P -ahvz";
        };
      };

      bash = {
        enable = true;
        initExtra = ''
          if [[ -n "$PROMPT_COMMAND" ]]; then
              PROMPT_COMMAND="$PROMPT_COMMAND; exec ${pkgs.nushell}/bin/nu; unset PROMPT_COMMAND"
          else
              PROMPT_COMMAND='exec ${pkgs.nushell}/bin/nu; unset PROMPT_COMMAND'
          fi
        '';
      };

      carapace.enableNushellIntegration = (getAttrByNamespace config "${namespace}.cli.dev.carapace").enable;
      direnv.enableZshIntegration = (getAttrByNamespace config "${namespace}.cli.dev.direnv").enable;
      starship.enableNushellIntegration = (getAttrByNamespace config "${namespace}.cli.dev.starship").enable;
      yazi.enableNushellIntegration = (getAttrByNamespace config "${namespace}.cli.media.yazi").enable;
      zoxide.enableNushellIntegration = (getAttrByNamespace config "${namespace}.cli.dev.zoxide").enable;
    };
  };
}
