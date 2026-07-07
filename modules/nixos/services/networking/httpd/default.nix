{
  config,
  inputs,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mapAttrsToList listToAttrs replaceStrings mkMerge concatStringsSep filterAttrs optionalString;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace resolveHostIP isGateway flattenHostServices;
  inherit (config.networking) hostName;
  inherit (config.sops) secrets;

  base = "${namespace}.services.networking.httpd";
  cfg = getAttrByNamespace config base;
  networkingCfg = getAttrByNamespace config "${namespace}.services.networking";
  miasmaCfg = getAttrByNamespace config "${namespace}.services.apps.miasma";

  networkServices = networkingCfg.network-services;
  networkServicesFlat = flattenHostServices networkServices;

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
    enableAcme ? false,
    injectHoneypot ? false,
  }: host: name: service: let
    hostIP = resolveHostIP networkingCfg.devices host;
    p = toString service.port;

    certs = replaceStrings ["*" "."] ["wildcard" "_"] domain;
    sslConfig =
      if useSSL
      then
        {
          forceSSL = true;
        }
        // (
          if enableAcme
          then {
            useACMEHost = certs;
          }
          else {
            sslServerCert = secrets."ssl/${certs}/cert".path;
            sslServerKey = secrets."ssl/${certs}/key".path;
          }
        )
      else {};

    miasma = networkServicesFlat.miasma;

    honeypotConfig = optionalString injectHoneypot ''
      AddOutputFilterByType SUBSTITUTE text/html
      SubstituteMaxLineLength 30m
      Substitute 's|</body>|<a href="${miasmaCfg.linkPrefix}/" style="display:none" aria-hidden="true" tabindex="-1">Amazing high quality data here!</a></body>|i'

      ProxyPass ${miasmaCfg.linkPrefix}/ http://${resolveHostIP networkingCfg.devices miasma.host}:${toString miasma.port}/
      ProxyPassReverse ${miasmaCfg.linkPrefix}/ http://${resolveHostIP networkingCfg.devices miasma.host}:${toString miasma.port}/

      ProxyPass /robots.txt !
      Alias /robots.txt ${inputs.dotfiles}/httpd/robots/${name}.txt

    '';

    websocketConfig = optionalString service.websocket.enable ''
      # --- ${name} (websocket access) ---
      RewriteCond %{HTTP:Connection} upgrade [NC]
      RewriteCond %{HTTP:Upgrade} websocket [NC]
      RewriteRule ^/(.*)$ ws://${hostIP}:${p}${service.websocket.path}/$1 [P,L]

    '';
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

          Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
          Header always set Referrer-Policy "strict-origin-when-cross-origin"
          Header always set X-Content-Type-Options "nosniff"

          RewriteEngine On
          ProxyTimeout 300
          ProxyPreserveHost On

          ${honeypotConfig}

          ${websocketConfig}

          # --- ${name} (subdomain access) ---
          ProxyPass / http://${hostIP}:${p}/ connectiontimeout=30 timeout=300 retry=0
          ProxyPassReverse / http://${hostIP}:${p}/
        '';
      }
      // sslConfig;
  };
in {
  imports = [
    ./fail2ban.nix
  ];

  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "Apache HTTPD";
  };

  config = mkIf cfg.enable {
    services.httpd = {
      enable = true;

      extraModules = [
        "filter"
        "headers"
        "proxy"
        "proxy_http"
        "proxy_wstunnel"
        "reqtimeout"
        "rewrite"
        "substitute"
      ];

      extraConfig = ''
        ServerTokens Prod
        ServerSignature Off
        TraceEnable Off

        Timeout 30
        RequestReadTimeout handshake=5 header=10-20,minrate=500 body=10,minrate=500

        SSLProtocol -all +TLSv1.2 +TLSv1.3
        SSLCompression Off
        SSLSessionTickets Off

        ErrorDocument 400 /400.html
        ErrorDocument 401 /401.html
        ErrorDocument 403 /403.html
        ErrorDocument 404 /404.html
        ErrorDocument 500 /500.html
        ErrorDocument 503 /503.html
      '';

      virtualHosts = mkMerge [
        {
          "localhost" = let
            localhostProxyConfig =
              networkServices.${hostName}
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
              RewriteCond %{REQUEST_URI} !^/(400|401|403|404|500|503)\.html$
              RewriteRule ^ - [L,R=404]
            '';
          };
        }

        (networkServices.${hostName}
          |> filterAttrs (_: svc: svc.internal)
          |> mapAttrsToList (name: svc:
            (mkVirtualHost {
              domain = "*.yumeami.sh";
              useSSL = true;
            })
            hostName
            name
            svc)
          |> listToAttrs)

        (mkIf (isGateway networkingCfg.devices hostName) (
          networkServicesFlat
          |> filterAttrs (_: svc: svc.public)
          |> mapAttrsToList (name: svc:
            (mkVirtualHost {
              domain = "*.cpatino.com";
              useSSL = true;
              enableAcme = true;
              injectHoneypot = true;
            })
            svc.host
            name
            svc)
          |> listToAttrs
        ))

        {
          "_default_" = {
            documentRoot = "/var/empty";

            servedDirs = [
              {
                dir = "/var/www/error";
                urlPath = "/";
              }
            ];

            extraConfig = ''
              RewriteEngine On
              RewriteCond %{REQUEST_URI} !^/(400|401|403|404|500|503)\.html$
              RewriteRule ^ - [L,R=404]
            '';
          };
        }
        (
          mkIf (isGateway networkingCfg.devices hostName)
          {
            "zzz-undefined.cpatino.com" = {
              serverAliases = ["*.cpatino.com"];
              documentRoot = "/var/empty";

              servedDirs = [
                {
                  dir = "/var/www/error";
                  urlPath = "/";
                }
              ];

              extraConfig = ''
                RewriteEngine On
                RewriteCond %{REQUEST_URI} !^/(400|401|403|404|500|503)\.html$
                RewriteRule ^ - [L,R=404]
              '';

              forceSSL = true;
              useACMEHost = "wildcard_cpatino_com";
            };
          }
        )
        {
          "zzz-undefined.yumeami.sh" = {
            serverAliases = ["*.yumeami.sh"];
            documentRoot = "/var/empty";

            servedDirs = [
              {
                dir = "/var/www/error";
                urlPath = "/";
              }
            ];

            extraConfig = ''
              RewriteEngine On
              RewriteCond %{REQUEST_URI} !^/(400|401|403|404|500|503)\.html$
              RewriteRule ^ - [L,R=404]
            '';

            forceSSL = true;
            sslServerCert = secrets."ssl/wildcard_yumeami_sh/cert".path;
            sslServerKey = secrets."ssl/wildcard_yumeami_sh/key".path;
          };
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [80 443];

    systemd.tmpfiles.rules = [
      "L+ /var/www 555 root root - ${inputs.dotfiles + "/httpd"}"
    ];

    sops.secrets = let
      inherit (config.networking) hostName;
      inherit (config.users.users) wwwrun;

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
      listToAttrs hostSpecific;
  };
}
