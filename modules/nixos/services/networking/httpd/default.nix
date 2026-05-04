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
  miasmaCfg = getAttrByNamespace config "${namespace}.services.networking.miasma";

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
    injectHoneypot ? false,
  }: name: service: let
    inherit (config.sops) secrets;
    host = resolveHostIP networkingCfg.devices service.host;
    p = toString service.port;

    certs = replaceStrings ["*" "."] ["wildcard" "_"] domain;
    sslConfig =
      if useSSL
      then {
        forceSSL = true;
        sslServerCert = secrets."ssl/${certs}/cert".path;
        sslServerKey = secrets."ssl/${certs}/key".path;
      }
      else {};

    honeypotConfig =
      if injectHoneypot && miasmaCfg.enable
      then ''
        AddOutputFilterByType SUBSTITUTE text/html
        SubstituteMaxLineLength 30m
        Substitute 's|</body>|<a href="${miasmaCfg.linkPrefix}" style="display:none" aria-hidden="true" tabindex="-1">Amazing high quality data here!</a></body>|i'
      ''
      else "";

    robotsConfig =
      if injectHoneypot
      then ''
        Alias /robots.txt ${inputs.dotfiles}/httpd/robots/${name}.txt
      ''
      else "";
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

          ${honeypotConfig}

          ${robotsConfig}

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

      extraModules = [
        "filter"
        "proxy"
        "proxy_http"
        "rewrite"
        "substitute"
      ];

      extraConfig = ''
        ErrorDocument 400 /400.html
        ErrorDocument 401 /401.html
        ErrorDocument 403 /403.html
        ErrorDocument 404 /404.html
        ErrorDocument 500 /500.html

        ProxyPass ${miasmaCfg.linkPrefix} http://miasma.yumeami.sh/
        ProxyPassReverse ${miasmaCfg.linkPrefix} http://miasma.yumeami.sh/
      '';

      virtualHosts = mkMerge [
        {
          "_default_" = {
            acmeRoot = null;
            documentRoot = "/var/empty";

            servedDirs = [
              {
                dir = "/var/www/error";
                urlPath = "/";
              }
            ];

            extraConfig = ''
              RewriteEngine On
              RewriteCond %{REQUEST_URI} !^/(400|401|403|404|500)\.html$
              RewriteRule ^ - [L,R=404]
            '';
          };
        }

        {
          "_default_" = let
            inherit (config.sops) secrets;
          in {
            acmeRoot = null;
            documentRoot = "/var/empty";

            servedDirs = [
              {
                dir = "/var/www/error";
                urlPath = "/";
              }
            ];

            extraConfig = ''
              RewriteEngine On
              RewriteCond %{REQUEST_URI} !^/(400|401|403|404|500)\.html$
              RewriteRule ^ - [L,R=404]
            '';

            forceSSL = true;
            sslServerCert = secrets."ssl/wildcard_cpatino_com/cert".path;
            sslServerKey = secrets."ssl/wildcard_cpatino_com/key".path;
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

            servedDirs = [
              {
                dir = "/var/www/error";
                urlPath = "/";
              }
            ];

            extraConfig = ''
              UseCanonicalName Off

              RewriteEngine On
              ${localhostProxyConfig}
              RewriteCond %{REQUEST_URI} !^/(400|401|403|404|500)\.html$
              RewriteRule ^ - [L,R=404]
            '';
          };
        }

        (networkingCfg.network-services
          |> filterAttrs (_: svc: svc.host == hostName && svc.internal)
          |> mapAttrsToList (mkVirtualHost {
            domain = "*.yumeami.sh";
            useSSL = true;
            injectHoneypot = true;
          })
          |> listToAttrs)

        (mkIf networkingCfg.cloudflared.enable (networkingCfg.network-services
          |> filterAttrs (_: svc: svc.public)
          |> mapAttrsToList (mkVirtualHost {
            domain = "*.cpatino.com";
            useSSL = false;
            injectHoneypot = true;
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

    systemd.tmpfiles.rules = [
      "L+ /var/www 555 root root - ${inputs.dotfiles + "/httpd"}"
    ];

    sops.secrets = let
      inherit (config.networking) hostName;
      inherit (config.users.users) wwwrun;

      global =
        [
          "ssl/wildcard_cpatino_com/cert"
          "ssl/wildcard_cpatino_com/key"
        ]
        |> map (name: {
          inherit name;
          value = {
            owner = wwwrun.name;
            group = wwwrun.group;
          };
        });

      hostSpecific =
        [
          "ssl/wildcard_yumeami_sh/cert"
          "ssl/wildcard_yumeami_sh/key"
        ]
        |> map (name: {
          inherit name;
          value = {
            sopsFile = "${inputs.self}/secrets/sops/${hostName}.yaml";
            owner = wwwrun.name;
            group = wwwrun.group;
          };
        });
    in
      listToAttrs (global ++ hostSpecific);
  };
}
