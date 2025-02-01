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
  in {
    arisu = nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      modules = [
        ./arisu
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = extraSpecialArgs "arisu";
            users.c4patino = {imports = homeImports."c4patino@arisu";};
          };
        }
      ];
    };
    kokoro = nixosSystem {
      inherit specialArgs;
      system = "x86_64-linux";
      modules = [./kokoro];
    };
    chibi = nixosSystem {
      inherit specialArgs;
      system = "aarch64-linux";
      modules = [./chibi];
    };
    hikari = nixosSystem {
      inherit specialArgs;
      modules = [
        ./hikari
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            users.nixos = {imports = homeImports."c4patino@hikari";};
          };
        }
      ];
    };
  };
}
