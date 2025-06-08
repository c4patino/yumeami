{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
with lib;
with lib.${namespace}; let
  inherit (config.networking) hostName;
  base = "${namespace}.bundles.common";
  cfg = getAttrByNamespace config base;
in {
  config = mkIf cfg.enable {
    ${namespace} = {
    };

    users.users.c4patino = {
      isNormalUser = true;
      description = "C4 Patino";
      extraGroups = ["networkmanager" "wheel" "vboxusers" "docker" "podman" "syncthing"];

      hashedPassword = "$6$XM5h391mH33WIoAy$xkeSzw/ootPPZbvHEqSguZDyB4gAeTMcjy1aRXcXcQWFkS1/SRPK27VgEYC.vYvdZLYWALZtpdEzWAfwT4VCM1";

      openssh.authorizedKeys.keyFiles = let
        ssh = "${inputs.self}/secrets/crypt/ssh";
      in
        ["arisu" "chibi" "kokoro" "shiori"]
        |> map (h: "${ssh}/${h}/id_ed25519.pub");

      shell = pkgs.zsh;
    };

    programs.zsh = enabled;

    sops = let
      inherit (config.users.users) c4patino;
    in {
      secrets = {
        "master-password" = {owner = c4patino.name;};

        "forgejo" = {owner = c4patino.name;};

        "github/auth" = {owner = c4patino.name;};
        "github/runner" = {owner = c4patino.name;};
        "github/runner-oasys" = {owner = c4patino.name;};

        "tailscale/actions" = {owner = c4patino.name;};
        "tailscale/tsdproxy" = {owner = c4patino.name;};

        "cloudflare" = {owner = c4patino.name;};

        "pypi" = {owner = c4patino.name;};

        "rustypaste" = {owner = c4patino.name;};
      };

      age.keyFile = let
        crypt = "/persist/${c4patino.home}/dotfiles/secrets/crypt";
      in "${crypt}/age/${hostName}/keys.txt";
    };
  };
}
