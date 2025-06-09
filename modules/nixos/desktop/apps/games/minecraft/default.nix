{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption mapAttrs mapAttrsToList flatten;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.desktop.apps.games.minecraft";
  cfg = getAttrByNamespace config base;
in {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];

  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Minecraft Server";
      servers = mkOption {
        type = attrsOf (submodule {
          options = {
            package = mkOption {
              type = package;
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

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [tmux];

    networking.firewall.allowedTCPPorts =
      cfg.servers
      |> mapAttrsToList
      |> flatten;

    nixpkgs.overlays = [inputs.nix-minecraft.overlay];

    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers =
        cfg.servers
        |> mapAttrs (name: cfg: {
          inherit (cfg) package jvmOpts serverProperties whitelist;
          enable = true;
        });
    };

    ${namespace}.services.storage.impermanence.folders = ["/srv/minecraft"];
  };
}
