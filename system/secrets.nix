{
  self,
  inputs,
  config,
  ...
}: let
  inherit (config.users.users) c4patino;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${self}/secrets/sops/secrets.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "${c4patino.home}/.config/sops/age/keys.txt";
    secrets = {
      "github/auth" = {owner = c4patino.name;};
      "github/runner" = {owner = c4patino.name;};
      "github/runner-oasys" = {owner = c4patino.name;};
      "master-password" = {owner = c4patino.name;};
      "tailscale/actions" = {owner = c4patino.name;};
      "pypi" = {owner = c4patino.name;};
    };
  };
}
