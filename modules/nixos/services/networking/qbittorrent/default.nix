{
  config,
  inputs,
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
  torrentingPort = 23345;
in {
  config = mkIf isEnabled {
    services = {
      qbittorrent = {
        enable = true;
        openFirewall = true;

        webuiPort = port;
        torrentingPort = torrentingPort;

        serverConfig = {
          BitTorrent.Session = {
            Interface = "tun0";
            InterfaceName = "tun0";
            BTProtocol = "UTP";
          };

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

      openvpn = {
        restartAfterSleep = true;
        servers = {
          default = {
            autoStart = true;

            config = "config ${inputs.self}/secrets/crypt/openvpn/us10326.nordvpn.com.udp.ovpn";
            authUserPass = config.sops.secrets."openvpn".path;
          };
        };
      };
    };

    sops.secrets = {
      "openvpn" = {};
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

    networking.firewall.allowedUDPPorts = [torrentingPort];
  };
}
