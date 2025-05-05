{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) types mkEnableOption mkOption;
  cfg = config.mcservers;
in {
  options.mcservers = with types; {
    enable = mkEnableOption "custom minecraft servers";
    servers = mkOption {
      type = attrsOf (submodule {
        options = {
          package = mkOption {
            type = package;
            default = null;
            description = "The Minecraft server package to use.";
          };

          jvmOpts = mkOption {
            type = str;
            default = "-Xms4092M -Xmx4092M -XX:+UseG1GC";
            description = "JVM options for the Minecraft server.";
          };

          serverProperties = mkOption {
            type = attrs;
            default = {};
            description = "Minecraft server properties.";
          };

          whitelist = mkOption {
            type = attrs;
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

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [tmux];

    networking.firewall.allowedTCPPorts =
      cfg.servers
      |> lib.mapAttrsToList
      |> lib.flatten;

    nixpkgs.overlays = [inputs.nix-minecraft.overlay];

    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers =
        cfg.servers
        |> lib.mapAttrs (name: cfg: {
          inherit (cfg) package jvmOpts serverProperties whitelist;
          enable = true;
        });
    };

    impermanence.folders = ["/srv/minecraft"];
  };
}
