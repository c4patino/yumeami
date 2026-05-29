{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService getServicePort flattenHostServices;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  isEnabled = hostHasService networkCfg.network-services hostName "qbittorrent";
  port = getServicePort networkServices "qbittorrent" 9000;
in {
  config = mkIf isEnabled {
    services.qbittorrent = {
      enable = true;
      openFirewall = true;
      webuiPort = port;
      serverConfig = {
        LegalNotice.Accepted = true;
        Preferences = {
          WebUI = {
            Username = "c4patino";
            Password_PBKDF2 = "@ByteArray(rCUYopB8giM6MP/g7F3+dQ==:Y7igij6jhBLHiSg9irzHMOCzfr67aH9xsrpUHnHt9CeBcsVP0xpacy0AXTokpINAtoFcX7TATVANdJNUAlsVeA==)";
          };
          General.Locale = "en";
        };
      };
    };

    ${namespace}.services.storage.impermanence.folders = let
      qbittorrentUser = config.users.users.qbittorrent;
    in [
      {
        directory = "/var/lib/qBittorrent";
        user = qbittorrentUser.name;
        group = qbittorrentUser.group;
        mode = "700";
      }
    ];
  };
}
