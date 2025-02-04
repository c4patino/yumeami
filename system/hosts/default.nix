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

    # TODO: Make it such that homeManager inputs it's own import into modules
    homeManager = hostName: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = specialArgs hostName;
        users.c4patino = {imports = homeImports."c4patino@${hostName}";};
      };
    };
  in {
    arisu = nixosSystem {
      specialArgs = specialArgs "arisu";
      system = "x86_64-linux";
      modules = [
        ./arisu
        inputs.home-manager.nixosModules.home-manager
        (homeManager "arisu")
      ];
    };
    kokoro = nixosSystem {
      specialArgs = specialArgs "kokoro";
      system = "x86_64-linux";
      modules = [
        ./kokoro
        inputs.home-manager.nixosModules.home-manager
        (homeManager "kokoro")
      ];
    };
    chibi = nixosSystem {
      specialArgs = specialArgs "chibi";
      system = "aarch64-linux";
      modules = [
        ./chibi
        inputs.home-manager.nixosModules.home-manager
        (homeManager "chibi")
      ];
    };
    hikari = nixosSystem {
      specialArgs = specialArgs "hikari";
      modules = [
        ./hikari
        inputs.home-manager.nixosModules.home-manager
        (homeManager "hikari")
      ];
    };
  };
}
