{
  self,
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkMerge filterAttrs mapAttrsToList concatStringsSep listToAttrs replaceStrings;
  inherit (config.sops) secrets;
  inherit (config.networking) hostName;
  cfg = config.httpd;

  mkLocalhostConfig = name: service: let
    p = toString service.port;
  in ''
    # --- ${name} (subdomain access) ---
    RewriteCond %{HTTP_HOST} ^${name}\.localhost$ [NC]
    RewriteRule ^/(.*) http://localhost:${p}/$1 [P,L]
    ProxyPassReverse / http://localhost:${p}/
  '';

  mkVirtualHost = {
    domain,
    useSSL,
  }: name: service: let
    ssl = "${self}/secrets/crypt/ssl/${hostName}";
    p = toString service.port;

    certs = replaceStrings ["*"] ["wildcard"] domain;
    sslConfig =
      if useSSL
      then {
        forceSSL = true;
        sslServerKey = "${ssl}/${certs}.key";
        sslServerCert = "${ssl}/${certs}.crt";
      }
      else {};
  in {
    name = replaceStrings ["*"] [name] domain;
    value =
      {
        acmeRoot = null;
        documentRoot = "/var/empty";
        extraConfig = ''
          UseCanonicalName Off
          RewriteEngine On

          # --- ${name} (subdomain access) ---
          RewriteRule ^/(.*) http://localhost:${p}/$1 [P,L]
          ProxyPassReverse / http://localhost:${p}/
        '';
      }
      // sslConfig;
  };

  localhostProxyConfig =
    config.network-services
    |> mapAttrsToList mkLocalhostConfig
    |> concatStringsSep "\n";

  internalVirtualHosts =
    config.network-services
    |> filterAttrs (_: svc: svc.host == hostName)
    |> mapAttrsToList (mkVirtualHost {
      domain = "*.yumeami.sh";
      useSSL = true;
    })
    |> listToAttrs;
in {
  options.httpd.enable = mkEnableOption "httpd";

  config = mkIf cfg.enable {
    services.httpd = {
      enable = true;

      extraModules = ["proxy" "proxy_http" "rewrite"];

      virtualHosts = mkMerge [
        {
          "localhost" = {
            acmeRoot = null;
            serverAliases = ["*.localhost"];
            documentRoot = "/var/empty";
            extraConfig = ''
              UseCanonicalName Off
              RewriteEngine On
              ${localhostProxyConfig}

              RewriteRule ^ - [R=404,L]
            '';
          };
        }

        internalVirtualHosts
      ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "c4patino@gmail.com";
      defaults = {
        dnsProvider = "cloudflare";
        dnsProviderConfig = {
          CF_Token = secrets."cloudflare";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];

    impermanence.folders = ["/var/www"];
  };
}
