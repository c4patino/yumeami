{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) types;
in {
  options.mcservers = {
    enable = lib.mkEnableOption "custom minecraft servers";
    servers = lib.mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          package = lib.mkOption {
            type = types.package;
            default = null;
            description = "The Minecraft server package to use.";
          };

          jvmOpts = lib.mkOption {
            type = types.str;
            default = "-Xms4092M -Xmx4092M -XX:+UseG1GC";
            description = "JVM options for the Minecraft server.";
          };

          serverProperties = lib.mkOption {
            type = types.attrs;
            default = {};
            description = "Minecraft server properties.";
          };

          whitelist = lib.mkOption {
            type = types.attrs;
            default = {};
            description = "Whitelist for the Minecraft server.";
          };
        };
      });
      default = {};
      description = "Minecraft server configurations.";
    };
  };

  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];

  config = lib.mkIf config.mcservers.enable {
    environment.systemPackages = with pkgs; [tmux];

    networking.firewall.allowedTCPPorts =
      config.mcservers.servers
      |> lib.mapAttrsToList
      |> lib.flatten;

    nixpkgs.overlays = [inputs.nix-minecraft.overlay];

    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers =
        config.mcservers.servers
        |> lib.mapAttrs (name: cfg: {
          inherit (cfg) package jvmOpts serverProperties whitelist;
          enable = true;
        });
    };
  };
}
