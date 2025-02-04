{
  lib,
  config,
  ...
}: {
  options.ssh.enable = lib.mkEnableOption "ssh configurations";

  config = lib.mkIf config.ssh.enable {
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host github
            HostName github.com
            User git

        Host swan
            HostName swan.unl.edu
            User c4patino
            ControlMaster auto
            ControlPath /tmp/ssh_%r@%h:%p
            ControlPersist 2h

        Host cse
            HostName cse.unl.edu
            User cpatino
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
