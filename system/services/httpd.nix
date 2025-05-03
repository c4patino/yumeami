{
  lib,
  config,
  ...
}: let
  inherit (lib) types;
  inherit (config.sops) secrets;

  mkDomainConfig = domain: service: let
    n = service.name;
    p = toString service.port;
  in ''
    # --- ${n} (subdomain access) ---
    RewriteCond %{HTTP_HOST} ^${n}\.${domain}$ [NC]
    RewriteRule ^/(.*) http://localhost:${p}/$1 [P,L]
    ProxyPassReverse / http://localhost:${p}/
  '';

  mkPublicVirtualHost = service: let
    n = service.name;
    p = toString service.port;
  in {
    name = "${n}.cpatino.com";
    value = {
      acmeRoot = null;
      documentRoot = "/var/empty";
      extraConfig = ''
        UseCanonicalName Off
        RewriteEngine On

        # --- ${n} (subdomain access) ---
        RewriteRule ^/(.*) http://localhost:${p}/$1 [P,L]
        ProxyPassReverse / http://localhost:${p}/
      '';
    };
  };

  localhostProxyConfig = lib.concatStringsSep "\n" (map (mkDomainConfig "localhost") config.httpd.services);
  publicVirtualHosts = lib.listToAttrs (map mkPublicVirtualHost (lib.filter (s: s.public) config.httpd.services));
in {
  options.httpd = {
    enable = lib.mkEnableOption "httpd";
    services = lib.mkOption {
      type = with types;
        listOf (submodule {
          options = {
            name = lib.mkOption {
              type = str;
              description = "Name of the service, used in path and subdomain";
            };
            port = lib.mkOption {
              type = port;
              description = "Local port of the service";
            };
            public = lib.mkOption {
              type = bool;
              description = "Whether the service should be publicly accessible.";
              default = false;
            };
          };
        });
      default = [];
      description = "List of apps to reverse-proxy using Apache";
    };
  };

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

        publicVirtualHosts
      ];
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "c4patino@gmail.com";
      defaults = {
        dnsProvider = "cloudflare";
        dnsProviderConfig = lib.mkOption {
          type = lib.types.attrs;
          default = {
            CF_Token = secrets."cloudflare";
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];
  };
}
