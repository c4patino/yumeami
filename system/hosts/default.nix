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
      system,
      username ? "c4patino",
    }:
      nixosSystem {
        inherit system;
        specialArgs = specialArgs hostname;
        modules = [../. ./${hostname}] ++ homeManager {inherit hostname username;};
      };
  in {
    arisu = mkSystem {
      hostname = "arisu";
      system = "x86_64-linux";
    };
    kokoro = mkSystem {
      hostname = "kokoro";
      system = "x86_64-linux";
    };
    chibi = mkSystem {
      hostname = "chibi";
      system = "aarch64-linux";
    };
    shiori = mkSystem {
      hostname = "shiori";
      system = "x86_64-linux";
    };

    hikari = mkSystem {
      hostname = "hikari";
      system = "x86_64-linux";
      username = "nixos";
    };
  };
}
