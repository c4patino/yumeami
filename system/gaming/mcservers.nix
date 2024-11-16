{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options = {
    mcservers.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable custom minecraft servers";
    };
  };

  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];

  config = lib.mkIf config.mcservers.enable {
    environment.systemPackages = with pkgs; [tmux];

    networking.firewall = {
      allowedTCPPorts = [25565];
    };

    nixpkgs.overlays = [inputs.nix-minecraft.overlay];

    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers = {
        vanilla = {
          enable = true;
          package = pkgs.vanillaServers.vanilla-1_21_3;
          jvmOpts = "-Xms4092M -Xmx4092M -XX:+UseG1GC";
          serverProperties = {
            difficulty = "hard";
            server-port = 25565;
          };
          whitelist = {};
        };
        modded = {
          enable = true;
          package = pkgs.fabricServers.fabric-1_21_3;
          jvmOpts = "-Xms4092M -Xmx4092M -XX:+UseG1GC";
          serverProperties = {
            difficulty = "hard";
            server-port = 25566;
          };
          whitelist = {};
        };
      };
    };
  };
}
