{
  config,
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

          # take command
          def --env take [dir: path] {
            mkdir $dir
            cd $dir
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

          def clip [] {
            if ("WSL_DISTRO_NAME" in ($env | columns)) {
              clip.exe
            } else if (which wl-copy | is-not-empty) {
              wl-copy
            } else if (which xclip | is-not-empty) {
              xclip -selection clipboard
            } else if (which pbcopy | is-not-empty) {
              pbcopy
            } else {
              error make {msg: "No clipboard utility found"}
            }
          }

          # secret copy command
          def sc [path: string] {
            ["/run/secrets" $path]
            | path join
            | open
            | clip
          }

          # flat sha256 of a file, as used by fetchurl (pass --unpack for fetchzip's NAR hash)
          def nix-prefetch-url-hash [url: string, --unpack] {
            let raw = if $unpack {
              nix-prefetch-url --unpack $url
            } else {
              nix-prefetch-url $url
            }

            let hash = (nix hash convert --hash-algo sha256 --to sri $raw)

            $hash | clip
            $hash
          }

          # NAR sha256 of an unpacked source tree, as used by fetchFromGitHub
          def nix-prefetch-github-hash [spec: string] {
            let parts = ($spec | split row "/")
            if (($parts | length) < 4) {
              error make {msg: "expected <host>/<owner>/<repo>/<tag>"}
            }

            let host = ($parts | get 0)
            let owner = ($parts | get 1)
            let repo = ($parts | get 2)
            let tag = ($parts | skip 3 | str join "/")

            let url = $"https://($host)/($owner)/($repo)/archive/($tag).tar.gz"
            let hash = (nix hash convert --hash-algo sha256 --to sri (nix-prefetch-url --unpack $url))

            $hash | clip
            $hash
          }
        '';

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
