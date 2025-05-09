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
    age.keyFile = let
      crypt = "/persist/${c4patino.home}/dotfiles/secrets/crypt";
    in "${crypt}/age/${hostName}/keys.txt";
    secrets = {
      "master-password" = {owner = c4patino.name;};

      "github/auth" = {owner = c4patino.name;};
      "github/runner" = {owner = c4patino.name;};
      "github/runner-oasys" = {owner = c4patino.name;};

      "tailscale/actions" = {owner = c4patino.name;};
      "tailscale/tsdproxy" = {owner = c4patino.name;};

      "cloudflare" = {owner = c4patino.name;};

      "pypi" = {owner = c4patino.name;};

      "rustypaste" = {owner = c4patino.name;};
    };
  };
}
