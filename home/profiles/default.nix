{
  inputs,
  self,
  ...
}: let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/crypt/secrets.json");

  specialArgs = hostName: {
    inherit inputs self secrets hostName;
  };

  homeImports = {
    "c4patino@arisu" = [../. ./arisu];
    "c4patino@chibi" = [../. ./chibi];
    "c4patino@kokoro" = [../. ./kokoro];
    "c4patino@hikari" = [../. ./hikari];
  };
in {
  _module.args = {inherit homeImports;};
  flake.homeConfigurations = {
    "c4patino@arisu" = homeManagerConfiguration {
      modules = homeImports."c4patino@arisu";
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = specialArgs "arisu";
    };
    "c4patino@kokoro" = homeManagerConfiguration {
      modules = homeImports."c4patino@kokoro";
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = specialArgs "kokoro";
    };
    "c4patino@chibi" = homeManagerConfiguration {
      modules = homeImports."c4patino@chibi";
      pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = specialArgs "chibi";
    };
    "c4patino@hikari" = homeManagerConfiguration {
      modules = homeImports."c4patino@hikari";
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = specialArgs "hikari";
    };
  };
}
