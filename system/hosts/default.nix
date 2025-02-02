{
  self,
  inputs,
  homeImports,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;

    secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/crypt/secrets.json");

    specialArgs = {inherit inputs self;};
    extraSpecialArgs = hostName: {
      inherit inputs self secrets hostName;
    };

    home-manager = hostName: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = extraSpecialArgs hostName;
        users.c4patino = {imports = homeImports."c4patino@${hostName}";};
      };
    };
  in {
    arisu = nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      modules = [
        inputs.home-manager.nixosModules.home-manager
        ./arisu
        (home-manager "arisu")
      ];
    };
    kokoro = nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      modules = [
        inputs.home-manager.nixosModules.home-manager
        ./kokoro
        (home-manager "kokoro")
      ];
    };
    chibi = nixosSystem {
      inherit specialArgs;
      system = "aarch64-linux";
      modules = [
        inputs.home-manager.nixosModules.home-manager
        ./chibi
        (home-manager "chibi")
      ];
    };
    hikari = nixosSystem {
      inherit specialArgs;
      modules = [
        inputs.home-manager.nixosModules.home-manager
        ./hikari
        (home-manager "hikari")
      ];
    };
  };
}
