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
            github-auth = { };
            github-runner = { };
            github-runner-oasys = { };
        };
    };
}
