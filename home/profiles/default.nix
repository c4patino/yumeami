{ inputs, self, ... }: 
let 
    extraSpecialArgs = { inherit inputs self secrets; };

    homeImports = {
        "c4patino@arisu" = [
            ../.
            ./arisu
        ];
        "c4patino@kokoro" = [
            ../.
            ./kokoro
        ];
        "c4patino@hikari" = [
            ../.
            ./hikari
        ];
    };

    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

    secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/crypt/secrets.json");
in
{
    _module.args = { inherit homeImports; };

    flake = {
        homeConfigurations = {
            "c4patino@arisu" = inputs.home-manager.lib.homeManagerConfiguration {
                modules = homeImports."c4patino@arisu";
                inherit pkgs extraSpecialArgs;
            };
            "c4patino@kokoro" = inputs.home-manager.lib.homeManagerConfiguration {
                modules = homeImports."c4patino@kokoro";
                inherit pkgs extraSpecialArgs;
            };
        };
    };

}
