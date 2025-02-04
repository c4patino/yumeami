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

    homeManager = hostName: [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = specialArgs hostName;
          users.c4patino = {imports = homeImports."c4patino@${hostName}";};
        };
      }
    ];
  in {
    arisu = nixosSystem {
      specialArgs = specialArgs "arisu";
      system = "x86_64-linux";
      modules = [./arisu] ++ homeManager "arisu";
    };
    kokoro = nixosSystem {
      specialArgs = specialArgs "kokoro";
      system = "x86_64-linux";
      modules = [./kokoro] ++ homeManager "kokoro";
    };
    chibi = nixosSystem {
      specialArgs = specialArgs "chibi";
      system = "aarch64-linux";
      modules = [./chibi] ++ homeManager "chibi";
    };
    hikari = nixosSystem {
      specialArgs = specialArgs "hikari";
      modules = [./hikari] ++ homeManager "hikari";
    };
  };
}
