{
  config,
  host,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = {
    home.packages = with pkgs; [sops];

    sops = let
      inherit (config.snowfallorg) user;
    in {
      age.keyFile = let
        crypt = "${user.home.directory}/dotfiles/secrets/crypt";
      in "${crypt}/age/${host}/keys.txt";

      defaultSopsFile = "${inputs.self}/secrets/sops/secrets.yaml";
      defaultSopsFormat = "yaml";
    };
  };
}
