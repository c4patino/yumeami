{ self, inputs, config, ... }: {
	imports = [
		inputs.sops-nix.nixosModules.sops
	];

    sops = {
        defaultSopsFile = "${self}/secrets/sops/secrets.yaml";
        defaultSopsFormat = "yaml";
        age = {
            keyFile = "/home/c4patino/.config/sops/age/keys.txt";
            generateKey = true;
        };
        secrets = {
			"github/auth" = {
				owner = config.users.users.c4patino.name;
			};
			"github/runner" = {
				owner = config.users.users.c4patino.name;
			};
			"github/runner-oasys" = {
				owner = config.users.users.c4patino.name;
			};
			"master-password" = {
				owner = config.users.users.c4patino.name;
			};
        };
    };
}
