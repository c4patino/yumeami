{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) filterAttrs flatten hasSuffix mapAttrs mapAttrsToList mkEnableOption mkIf mkMerge throwIf types;
  inherit (lib.${namespace}) getAttrByNamespace mkOpt mkOptAttrset mkOptionsWithNamespace mkPersistRootDir;
  base = "${namespace}.desktop.apps.games.minecraft";
  cfg = getAttrByNamespace config base;

  nmLib = inputs.nix-minecraft.lib;
  nmPkgs = pkgs.extend inputs.nix-minecraft.overlay;

  manifestFiles = [
    "index.json"
    "modrinth.index.json"
    "pack.toml"
    "packwiz.json"
  ];

  detectPackType = src:
    if hasSuffix ".mrpack" (toString src)
    then "modrinth"
    else if lib.pathExists (src + "/pack.toml")
    then "packwiz"
    else "plain";

  installerArgs = pack: {
    inherit (pack) src packHash side;
  };

  fetchers = {
    modrinth = pack: nmPkgs.fetchModrinthModpack (installerArgs pack);
    packwiz = pack: nmPkgs.fetchPackwizModpack (installerArgs pack);
    plain = pack: pack.src;
  };

  fetchModpack = pack:
    throwIf (pack.src == null) "modpack.src must be set."
    (fetchers.${detectPackType pack.src} pack);

  modpackSymlinks = pack:
    fetchModpack pack
    |> nmLib.collectFiles
    |> filterAttrs (name: _: !(builtins.elem name manifestFiles));
in {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];

  options = with types;
    mkOptionsWithNamespace base {
      enable = mkEnableOption "Minecraft Server";
      servers = mkOptAttrset (submodule {
        options = {
          package = mkOpt package (throw "servers.<name>.package must be set.") "The Minecraft server package to use.";
          jvmOpts = mkOpt str "-Xms4092M -Xmx4092M -XX:+UseG1GC" "JVM options for the Minecraft server.";

          serverProperties = mkOpt attrs {} "Minecraft server properties.";
          whitelist = mkOpt attrs {} "Whitelist for the Minecraft server.";

          modpack =
            mkOpt (nullOr (submodule {
              options = {
                src = mkOpt (nullOr path) null ''
                  Modpack source: a .mrpack archive, a packwiz directory
                  (with pack.toml), or a prebuilt tree (e.g. pkgs.fetchzip of
                  a server-pack zip).
                '';
                packHash = mkOpt str lib.fakeHash "SHA-256 of the fetched pack tree; leave fakeHash to discover it on first build.";
                side = mkOpt (enum ["server" "client" "both"]) "server" "Which side's files to fetch from the pack.";
              };
            }))
            null "Modpack to deploy into the server directory.";

          symlinks = mkOpt attrs {} "Extra files to symlink, overriding the modpack contents.";
          files = mkOpt attrs {} "Extra writable files to copy, overriding the modpack contents.";
        };
      }) {} "Minecraft server configurations.";
    };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [tmux];

    networking.firewall.allowedTCPPorts =
      cfg.servers
      |> mapAttrsToList (_: server: server.serverProperties.server-port or 25565)
      |> flatten;

    nixpkgs.overlays = [inputs.nix-minecraft.overlay];

    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers =
        cfg.servers
        |> mapAttrs (name: server: {
          inherit (server) files jvmOpts package serverProperties whitelist;

          enable = true;

          symlinks = mkMerge [
            (mkIf (server.modpack != null) (modpackSymlinks server.modpack))
            server.symlinks
          ];
        });
    };

    ${namespace}.services.storage.impermanence.folders = [
      (mkPersistRootDir config "/srv/minecraft" "700")
    ];
  };
}
