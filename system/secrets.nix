{
  self,
  inputs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${self}/secrets/sops/secrets.yaml";
    defaultSopsFormat = "yaml";
  };
}
