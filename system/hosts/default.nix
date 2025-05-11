{
  self,
  inputs,
  homeImports,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;
    secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/crypt/secrets.json");

    specialArgs = hostName: {
      inherit inputs self secrets hostName;
      yumeami-lib = import ../../lib {};
    };

    homeManager = {
      username ? "c4patino",
      hostname,
    }: [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useUserPackages = true;
          extraSpecialArgs = specialArgs hostname;
          users.${username} = {imports = homeImports."${username}@${hostname}";};
        };
      }
    ];

    mkSystem = {
      hostname,
      username ? "c4patino",
      system ? "x86_64-linux",
    }:
      nixosSystem {
        inherit system;
        specialArgs = specialArgs hostname;
        modules = [../. ./${hostname}] ++ homeManager {inherit hostname username;};
      };
  in {
    arisu = mkSystem {hostname = "arisu";};
    kokoro = mkSystem {hostname = "kokoro";};
    shiori = mkSystem {hostname = "shiori";};

    chibi = mkSystem {
      hostname = "chibi";
      system = "aarch64-linux";
    };

    hikari = mkSystem {
      hostname = "hikari";
      username = "nixos";
    };
  };
}
