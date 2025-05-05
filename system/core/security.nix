{
  self,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [gnupg openssl];

  security = {
    polkit.enable = true;
    rtkit.enable = true;

    pki.certificateFiles = [
      "${self}/secrets/crypt/ssl/ca.crt"
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
