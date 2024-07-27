{ lib, config, pkgs, ... }: {
    options = {
        git.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable git, git-lfs, and gh-cli";
        };
    };

    config = lib.mkIf config.git.enable {
        programs.git = {
            enable = true;
            lfs.enable = true;
            userName = "C4 Patino";
            userEmail = "c4patino@gmail.com";

            extraConfig = {
                user.signingkey = "~/.ssh/id_ed25519.pub";
                init.defaultBranch = "main"; 
                pull.rebase = true; 
                fetch.prune = true; 

                maintenance.auto = true; 
                core.editor = "nvim"; 
                commit.gpgsign = true;
                gpg.format = "ssh"; 
                diff.colorMoved = "zebra";
            };
        };

        programs.gh = {
            enable = true;
            extensions = with pkgs; [ gh-copilot ];
        };
    };
}
