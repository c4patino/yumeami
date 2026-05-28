{
  inputs,
  self,
  ...
}: let
  sshUser = "root";
  sshOpts = [
    "-t"
    "-i"
    "~/.ssh/id_ed25519-deploy-rs"
  ];

  hosts = {
    arisu = {
      hostname = "arisu";
      system = "x86_64-linux";
    };
    arisu-windows = {
      hostname = "arisu-windows";
      system = "x86_64-linux";
    };
    kokoro = {
      hostname = "kokoro";
      system = "x86_64-linux";
    };
    kokoro-windows = {
      hostname = "kokoro-windows";
      system = "x86_64-linux";
    };
    shiori = {
      hostname = "shiori";
      system = "x86_64-linux";
    };
    tsuki = {
      hostname = "tsuki";
      system = "x86_64-linux";
    };
    chibi = {
      hostname = "chibi";
      system = "aarch64-linux";
    };
  };

  mkNode = name: {
    hostname,
    system,
  }: {
    inherit sshUser sshOpts hostname;
    profiles.system = {
      user = sshUser;
      path = inputs.deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${name};
    };
  };
in {
  deploy = {
    nodes =
      hosts
      |> builtins.mapAttrs mkNode;
  };
}
