{ self, ... }: {
    sops = {
        defaultSopsFile = "${self}/secrets/sops/secrets.yaml";
        defaultSopsFormat = "yaml";
        age = {
            keyFile = "/home/c4patino/.config/sops/age/keys.txt";
            generateKey = true;
        };
        secrets = {
            github-auth = {};
            github-runner = {};
            github-runner-oasys = {};
        };
    };

    home = {
        username = "c4patino";
        homeDirectory = "/home/c4patino";
        stateVersion = "23.11";
        sessionVariables = {
            FLAKE = "/home/c4patino/dotfiles";
        };
    };

	ssh.enable = true;
	zoxide.enable = true;
	zsh.enable = true;
	languages.enable = true;
	git.enable = true;
	lazygit.enable = true;

	bottom.enable = true;
	yazi.enable = true;

	neovim.enable = true;
} 
