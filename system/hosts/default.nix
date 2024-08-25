{ inputs, homeImports, ... }: {
    flake.nixosConfigurations = 
    let
        inherit (inputs.nixpkgs.lib) nixosSystem;
        specialArgs = { inherit inputs; };
    in 
    {
        arisu = nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [ ./arisu ];
        };
        kokoro = nixosSystem {
            inherit specialArgs;
            system = "x86_64-linux";
            modules = [ ./kokoro ];
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
                        users.nixos = {
                            imports = homeImports."c4patino@hikari";
                        };
                    };
                }
            ];
        };
    };
}
