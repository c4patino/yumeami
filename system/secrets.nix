{
  self,
  inputs,
  config,
  hostName,
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
    age.keyFile = "/persist/${c4patino.home}/dotfiles/secrets/crypt/${hostName}/keys.txt";
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
