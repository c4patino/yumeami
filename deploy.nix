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
    kokoro = {
      hostname = "kokoro";
      system = "x86_64-linux";
    };
    shiori = {
      hostname = "shiori";
      system = "x86_64-linux";
      groups = ["server"];
      activationTimeout = 1800;
    };
    tsuki = {
      hostname = "tsuki";
      system = "x86_64-linux";
      groups = ["server"];
    };
    chibi = {
      hostname = "chibi";
      system = "aarch64-linux";
      groups = ["server"];
    };
  };

  mkNode = name: {
    hostname,
    system,
    groups ? [],
    activationTimeout ? null,
  }: {
    inherit sshUser sshOpts hostname groups;
    inherit activationTimeout;
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
