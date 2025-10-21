{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mapAttrsToList listToAttrs replaceStrings mkMerge concatStringsSep filterAttrs;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace readJsonOrEmpty getIn resolveHostIP;
  inherit (config.networking) hostName;
  base = "${namespace}.services.networking.httpd";
  cfg = getAttrByNamespace config base;
  networkingCfg = getAttrByNamespace config "${namespace}.services.networking";

  crypt = "${inputs.self}/secrets/crypt";

  mkLocalhostConfig = name: service: let
    p = toString service.port;
  in ''
    # --- ${name} (localhost access) ---
    RewriteCond %{HTTP_HOST} ^${name}\.localhost$ [NC]
    RewriteRule ^/(.*) http://localhost:${p}/$1 [P,L]
    ProxyPassReverse / http://localhost:${p}/
  '';

  mkVirtualHost = {
    domain,
    useSSL,
  }: name: service: let
    ssl = "${crypt}/ssl/${hostName}";
    p = toString service.port;
    host = resolveHostIP networkingCfg.devices service.host;

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
          KeepAlive On
          MaxKeepAliveRequests 100
          KeepAliveTimeout 5

          RequestHeader set X-Forwarded-Proto "https"
          RequestHeader set X-Forwarded-Port "443"
          RequestHeader set X-Forwarded-For %{REMOTE_ADDR}s

          # --- ${name} (subdomain access) ---
          RewriteEngine On
          ProxyPreserveHost On
          ProxyPass / http://${host}:${p}/
          ProxyPassReverse / http://${host}:${p}/
        '';
      }
      // sslConfig;
  };
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Apache HTTPD";
  };

  config = mkIf cfg.enable {
    services.httpd = {
      enable = true;

      extraModules = ["proxy" "proxy_http" "rewrite"];

      virtualHosts = mkMerge [
        {
          "_default_" = {
            acmeRoot = null;
            documentRoot = "/var/empty";
            extraConfig = ''
              RewriteEngine On
              RewriteRule ^ - [R=404,L]
            '';
          };
        }

        {
          "localhost" = let
            localhostProxyConfig =
              networkingCfg.network-services
              |> mapAttrsToList mkLocalhostConfig
              |> concatStringsSep "\n";
          in {
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

        (networkingCfg.network-services
          |> filterAttrs (_: svc: svc.host == hostName)
          |> mapAttrsToList (mkVirtualHost {
            domain = "*.yumeami.sh";
            useSSL = true;
          })
          |> listToAttrs)

        (mkIf networkingCfg.cloudflared.enable (networkingCfg.network-services
          |> filterAttrs (_: svc: svc.public)
          |> mapAttrsToList (mkVirtualHost {
            domain = "*.cpatino.com";
            useSSL = false;
          })
          |> listToAttrs))
      ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "c4patino@gmail.com";
      defaults = {
        dnsProvider = "cloudflare";
        dnsProviderConfig = let
          secrets = readJsonOrEmpty "${crypt}/secrets.json";
        in {
          CF_Token = getIn secrets "cloudflare";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];

    ${namespace}.services.storage.impermanence.folders = ["/var/www"];
  };
}
