{
  config,
  lib,
  ...
}: {
  options.steam.enable = lib.mkEnableOption "Steam";

  config = lib.mkIf config.steam.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;

      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    programs.gamemode.enable = true;
  };
}
