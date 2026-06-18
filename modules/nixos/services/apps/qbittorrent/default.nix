{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) getAttrByNamespace hostHasService getServicePort flattenHostServices;
  inherit (config.networking) hostName;

  networkCfg = getAttrByNamespace config "${namespace}.services.networking";
  networkServices = flattenHostServices networkCfg.network-services;

  uid = 980;
  gid = 975;

  isEnabled = hostHasService networkCfg.network-services hostName "qbittorrent";
  port = getServicePort networkServices "qbittorrent" 9000;
  torrentingPort = 23345;
in {
  config = mkIf isEnabled {
    containers.qbittorrent = {
      autoStart = true;
      restartIfChanged = true;
      ephemeral = true;

      enableTun = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";

      bindMounts = {
        "/etc/openvpn/config" = {
          hostPath = "${inputs.self}/secrets/crypt/openvpn/us10326.nordvpn.com.udp.ovpn";
        };
        "/run/secrets/openvpn" = {
          hostPath = config.sops.secrets."openvpn".path;
        };
        "/var/lib/qBittorrent" = {
          hostPath = "/var/lib/qBittorrent";
          isReadOnly = false;
        };
        "/var/lib/qBittorrent/qBittorrent/downloads/seed" = {
          hostPath = "/var/lib/qBittorrent/qBittorrent/downloads/seed";
          isReadOnly = false;
        };
      };

      config = {
        services = {
          qbittorrent = {
            enable = true;
            openFirewall = true;

            webuiPort = port;
            torrentingPort = torrentingPort;

            serverConfig = {
              LegalNotice.Accepted = true;

              BitTorrent.Session = {
                Interface = "tun0";
                InterfaceName = "tun0";
                BTProtocol = "Both";

                Preallocation = true;

                DHTEnabled = true;
                PeXEnabled = true;
                LSDEnabled = false;

                BandwidthSchedulerEnabled = true;
                GlobalDLSpeedLimit = 0;
                GlobalUPSpeedLimit = 0;
                AlternativeGlobalDLSpeedLimit = 5120;
                AlternativeGlobalUPSpeedLimit = 5120;

                DisableAutoTMMByDefault = false;
                DisableAutoTMMTriggers = {
                  CategorySavePathChanged = false;
                  DefaultSavePathChanged = false;
                };

                QueueingSystemEnabled = true;
                MaxActiveDownloads = 8;
                MaxActiveUploads = 256;
                MaxActiveTorrents = 256;
                IgnoreSlowTorrentsForQueueing = true;
                SlowTorrentsDownloadRate = 5;
                SlowTorrentsUploadRate = 5;

                MaxConnections = -1;
                MaxConnectionsPerTorrent = -1;
                MaxUploads = -1;
                MaxUploadsPerTorrent = -1;
              };

              Preferences = {
                WebUI = {
                  Username = "c4patino";
                  Password_PBKDF2 = "@ByteArray(rCUYopB8giM6MP/g7F3+dQ==:Y7igij6jhBLHiSg9irzHMOCzfr67aH9xsrpUHnHt9CeBcsVP0xpacy0AXTokpINAtoFcX7TATVANdJNUAlsVeA==)";
                };

                General = {
                  Locale = "en";
                  StatusbarExternalIPDisplayed = true;
                };

                Scheduler = {
                  days = "Weekday";
                  end_time = "@Variant(\0\0\0\xf\x3\xa5\xd6\x80)";
                  start_time = "@Variant(\0\0\0\xf\x1\xee\x62\x80)";
                };

                Advanced.confirmTorrentDeletion = false;
              };
            };
          };
          openvpn = {
            restartAfterSleep = true;
            servers = {
              default = {
                autoStart = true;

                config = "config /etc/openvpn/config";
                authUserPass = "/run/secrets/openvpn";
              };
            };
          };
        };

        systemd.services = {
          qbittorrent = {
            requires = [
              "var-lib-qBittorrent.mount"
              "var-lib-qBittorrent-qBittorrent-downloads-seed.mount"
            ];

            after = [
              "openvpn-default.service"
              "var-lib-qBittorrent.mount"
              "var-lib-qBittorrent-qBittorrent-downloads-seed.mount"
            ];
          };
          openvpn-default = {
            upholds = ["qbittorrent.service"];
          };
        };

        users = {
          users.qbittorrent = {
            inherit uid;
            isSystemUser = true;
            group = "qbittorrent";
          };

          groups.qbittorrent = {
            inherit gid;
          };
        };

        networking.firewall = {
          allowedTCPPorts = [port torrentingPort];
          allowedUDPPorts = [torrentingPort];
        };

        system.stateVersion = "26.05";
      };
    };

    systemd.services.qbittorrent-localhost-proxy = {
      wantedBy = ["multi-user.target"];
      after = ["container@qbittorrent.service"];
      requires = ["container@qbittorrent.service"];

      serviceConfig = {
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},fork,bind=0.0.0.0,reuseaddr TCP:192.168.100.2:${toString port}";
        Restart = "always";
        RestartSec = 2;
      };
    };

    sops.secrets = {
      "openvpn" = {};
    };

    users = {
      users.qbittorrent = {
        inherit uid;
        isSystemUser = true;
        group = "qbittorrent";
      };

      groups.qbittorrent = {
        inherit gid;
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

    networking = {
      nat = {
        enable = true;

        internalInterfaces = ["ve-qbittorrent"];
        externalInterface = "enp1s0";
      };

      firewall = {
        allowedTCPPorts = [port];
        allowedUDPPorts = [torrentingPort];
      };
    };
  };
}
