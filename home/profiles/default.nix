{
  inputs,
  self,
  ...
}: let
  extraSpecialArgs = hostName: {
    inherit inputs self secrets;
    hostName = hostName;
  };

  homeImports = {
    "c4patino@arisu" = [
      ../.
      ./arisu
    ];
    "c4patino@chibi" = [
      ../.
      ./chibi
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

  secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/crypt/secrets.json");
in {
  _module.args = {inherit homeImports;};
  flake.homeConfigurations = {
    "c4patino@arisu" = inputs.home-manager.lib.homeManagerConfiguration {
      modules = homeImports."c4patino@arisu";
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = extraSpecialArgs "arisu";
    };
    "c4patino@kokoro" = inputs.home-manager.lib.homeManagerConfiguration {
      modules = homeImports."c4patino@kokoro";
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = extraSpecialArgs "kokoro";
    };
    "c4patino@chibi" = inputs.home-manager.lib.homeManagerConfiguration {
      modules = homeImports."c4patino@chibi";
      pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = extraSpecialArgs "chibi";
    };
  };
}
