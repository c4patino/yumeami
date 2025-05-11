{
  inputs,
  self,
  ...
}: let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/crypt/secrets.json");

  homeImports = {
    "c4patino@arisu" = [../. ./arisu];
    "c4patino@chibi" = [../. ./chibi];
    "c4patino@kokoro" = [../. ./kokoro];
    "c4patino@shiori" = [../. ./shiori];
    "nixos@hikari" = [../. ./hikari];
  };

  specialArgs = hostName: {
    inherit inputs self secrets hostName;
  };

  mkHomeManager = {
    hostname,
    username ? "c4patino",
    system ? "x86_64-linux",
  }:
    homeManagerConfiguration {
      modules = homeImports."${username}@${hostname}";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = specialArgs hostname;
    };
in {
  _module.args = {inherit homeImports;};
  flake.homeConfigurations = {
    "c4patino@arisu" = mkHomeManager {hostname = "arisu";};
    "c4patino@kokoro" = mkHomeManager {hostname = "kokoro";};
    "c4patino@shiori" = mkHomeManager {hostname = "shiori";};

    "c4patino@chibi" = mkHomeManager {
      hostname = "chibi";
      system = "aarch64-linux";
    };

    "nixos@hikari" = mkHomeManager {
      hostname = "hikari";
      username = "nixos";
    };
  };
}
