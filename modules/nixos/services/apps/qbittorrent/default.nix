{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.services.apps.qbittorrent";
  cfg = getAttrByNamespace config base;

  port = 9000;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "qbittorrent";
  };

  config = mkIf cfg.enable {
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
