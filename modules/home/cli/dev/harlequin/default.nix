{
  config,
  lib,
  namespace,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.dev.harlequin";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "harlequin";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        harlequin

        unixodbc
        oracle-instantclient
      ];

      file = let
        crypt = "${config.snowfallorg.user.home.directory}/dotfiles/secrets/crypt";
      in {
        ".config/harlequin/config.toml".source =
          "${crypt}/harlequin.toml"
          |> config.lib.file.mkOutOfStoreSymlink;

        ".config/odbc/.odbcinst.ini".text = ''
          [Oracle Instant Client 21]
          Description=Oracle ODBC driver
          Driver=${pkgs.oracle-instantclient.lib}/lib/libsqora.so.21.1
          FileUsage=1
        '';
      };

      sessionVariables = {
        ODBCSYSINI = "${config.snowfallorg.user.home.directory}/.config/odbc";
        ODBCINSTINI = ".odbcinst.ini";
      };
    };
  };
}
