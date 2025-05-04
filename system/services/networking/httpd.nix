{
  lib,
  config,
  ...
}: let
  inherit (config.sops) secrets;
  inherit (config.networking) hostName;

  mkLocalhostConfig = name: service: let
    p = toString service.port;
  in ''
    # --- ${name} (subdomain access) ---
    RewriteCond %{HTTP_HOST} ^${name}\.localhost$ [NC]
    RewriteRule ^/(.*) http://localhost:${p}/$1 [P,L]
    ProxyPassReverse / http://localhost:${p}/
  '';

  mkPublicVirtualHost = domain: name: service: let
    p = toString service.port;
  in {
    name = "${name}.${domain}";
    value = {
      acmeRoot = null;
      documentRoot = "/var/empty";
      extraConfig = ''
        UseCanonicalName Off
        RewriteEngine On

        # --- ${name} (subdomain access) ---
        RewriteRule ^/(.*) http://localhost:${p}/$1 [P,L]
        ProxyPassReverse / http://localhost:${p}/
      '';
    };
  };

  localhostProxyConfig =
    config.network-services
    |> lib.mapAttrsToList mkLocalhostConfig
    |> lib.concatStringsSep "\n";

  internalVirtualHosts =
    config.network-services
    |> lib.filterAttrs (_: svc: svc.host == hostName)
    |> lib.mapAttrsToList (mkPublicVirtualHost "yumeami.sh")
    |> lib.listToAttrs;
in {
  options.httpd.enable = lib.mkEnableOption "httpd";

  config = lib.mkIf config.httpd.enable {
    services.httpd = {
      enable = true;

      extraModules = ["proxy" "proxy_http" "rewrite"];

      virtualHosts = lib.mkMerge [
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
  };
}
