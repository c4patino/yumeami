{ pkgs, lib, config, inputs, ... }: {
    options = {
        zsh.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable zsh and its plugins";
        };
    };

    config = lib.mkIf config.zsh.enable {
        home.packages = with pkgs; [
            zsh-powerlevel10k
        ];

        home.file.".p10k.zsh".source = inputs.dotfiles + "/p10k.zsh";

        programs.zsh = {
            enable = true;
            enableCompletion = true;
            autosuggestion.enable = true;
            syntaxHighlighting.enable = true;

            initExtra = "source ~/.p10k.zsh";

            history = {
                size = 10000;
                path = "${config.xdg.dataHome}/zsh/history";
            };

            oh-my-zsh = {
                enable = true;
                plugins = [ "sudo" "git" "gitignore" "web-search" "copypath" "jsontools" ];
                theme = "robbyrussell";
            };

            plugins = [
                {
                    name = "powerlevel10k";
                    src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
                    file = "powerlevel10k.zsh-theme";
                }
            ];
        };
    };
}

