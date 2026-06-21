{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption mkOption mapAttrs mapAttrsToList flatten;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace mkOpt mkOptAttrset;
  base = "${namespace}.desktop.apps.games.minecraft";
  cfg = getAttrByNamespace config base;
in {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];

  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Minecraft Server";
      servers = mkOptAttrset (submodule {
        options = {
          package = mkOpt package null "The Minecraft server package to use.";
          jvmOpts = mkOpt str "-Xms4092M -Xmx4092M -XX:+UseG1GC" "JVM options for the Minecraft server.";
          serverProperties = mkOpt attrs {} "Minecraft server properties.";
          whitelist = mkOpt attrs {} "Whitelist for the Minecraft server.";
        };
      }) {} "Minecraft server configurations.";
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
