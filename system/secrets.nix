{
  self,
  inputs,
  config,
  ...
}: let
  userHome = config.users.users.c4patino.home;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${self}/secrets/sops/secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "${userHome}/.config/sops/age/keys.txt";
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
      "tailscale/actions" = {
        owner = config.users.users.c4patino.name;
      };
      "pypi" = {
        owner = config.users.users.c4patino.name;
      };
    };
  };
}
