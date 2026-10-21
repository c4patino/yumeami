{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.nushell";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "nushell";
  };

  config = mkIf cfg.enable {
    # custom commands and completions live in the dotfiles repo (source of truth)
    # and are autoloaded alphabetically from ~/.config/nushell/autoload/*.nu
    home.file."${config.programs.nushell.configDir}/autoload".source =
      inputs.dotfiles + "/.config/nushell/autoload";

    programs = {
      nushell = {
        enable = true;

        settings = {
          buffer_editor = "nvim";
          edit_mode = "vi";
          show_banner = false;

          keybindings = [
            {
              name = "fuzzy_history_fzf";
              modifier = "control";
              keycode = "char_r";
              mode = ["emacs" "vi_normal" "vi_insert"];
              event = {
                send = "executehostcommand";
                cmd = "fuzzy-history";
              };
            }
          ];
        };

        plugins = with pkgs.nushellPlugins; [
          polars
        ];

        shellAliases = {
          rsyncp = "rsync -P -ahvz";

          gcr = "git clone --recurse-submodules";

          gf = "git fetch";
          gfa = "git fetch --all";
          gfap = "git fetch --all --prune";

          gd = "git diff";
          gdw = "git diff --word-diff";
          gds = "git diff --staged";
          gdsw = "git diff --staged --word-diff";

          gl = "git log";
          glg = "git log --decorate --graph";
          glga = "git log --decorate --graph --all";
          glog = "git log --decorate --oneline --graph";
          gloga = "git log --decorate --oneline --graph --all";
        };
      };

      bash = {
        enable = true;
        enableCompletion = true;
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
