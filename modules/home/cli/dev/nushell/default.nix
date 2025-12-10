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
            keybindings: [
              {
                name: fuzzy_history_fzf
                modifier: control
                keycode: char_r
                mode: [emacs , vi_normal, vi_insert]
                event: {
                  send: executehostcommand
                  cmd: "commandline edit --replace (
                    history
                      | get command
                      | reverse
                      | uniq
                      | str join (char -i 0)
                      | fzf --scheme=history --read0 --tiebreak=chunk --layout=reverse --preview='echo {..}' --preview-window='bottom:3:wrap' --bind alt-up:preview-up,alt-down:preview-down --height=70% -q (commandline) --preview='echo -n {} | nu --stdin -c \'nu-highlight'''
                      | decode utf-8
                      | str trim
                  )"
                }
              }
            ]
          }

          # gitignore.io command
          def _gitignoreio_list [] {
            http get https://www.toptal.com/developers/gitignore/api/list
            | str replace -a "\n" ","
            | split row ","
            | str trim
            | where {|x| $x != ""}
          }

          def "nu-complete gi" [] {
            let fixed = ["list"]
            let templates = _gitignoreio_list
            $fixed ++ $templates
          }

          def gi [...args: string@"nu-complete gi"] {
            if ($args | where {|x| $x == "list"} | length) > 0 {
              return (_gitignoreio_list)
            }

            # Join templates with commas and fetch .gitignore
            let joined = ($args | sort | str join ",")
            http get $"https://www.toptal.com/developers/gitignore/api/($joined)"
          }

          # secret copy command
          def sc [path: string] {
            ["/run/secrets" ($path)]
            | path join
            | open
            | wl-copy
          }
        '';

        plugins = with pkgs.nushellPlugins; [
          polars
        ];

        shellAliases = {
          rsyncp = "rsync -P -ahvz";

          reboot = "sudo reboot";
          shutdown = "sudo shutdown";

          gloga = "git log --oneline --decorate --graph --all";
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
      direnv.enableNushellIntegration = (getAttrByNamespace config "${namespace}.cli.dev.direnv").enable;
      starship.enableNushellIntegration = (getAttrByNamespace config "${namespace}.cli.dev.starship").enable;
      yazi.enableNushellIntegration = (getAttrByNamespace config "${namespace}.cli.media.yazi").enable;
      zoxide.enableNushellIntegration = (getAttrByNamespace config "${namespace}.cli.dev.zoxide").enable;
    };
  };
}
