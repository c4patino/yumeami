{
  config,
  lib,
  namespace,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.${namespace}) getAttrByNamespace mkOptionsWithNamespace;
  base = "${namespace}.cli.access.ssh";
  cfg = getAttrByNamespace config base;
in {
  options = mkOptionsWithNamespace base {
    enable = mkEnableOption "ssh";
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host github
            HostName github.com
            User git
        Host forgejo
            HostName git.yumeami.sh
            User forgejo
            Port 2222

        Host swan
            HostName swan.unl.edu
            User c4patino
            ControlMaster auto
            ControlPath /tmp/ssh_%r@%h:%p
            ControlPersist 2h
        Host nuros
            HostName nuros.unl.edu
            User cpatino2
            ControlMaster auto
            ControlPath /tmp/ssh_%r@%h:%p
            ControlPersist 2h
      '';
    };
  };
}
